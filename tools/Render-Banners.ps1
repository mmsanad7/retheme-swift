<#
.SYNOPSIS
  Re-designs marketing banners: hue-shifts the photo, overlays new text/logos from an
  HTML template, and screenshots it with headless Chrome (proper Arabic shaping).

.DESCRIPTION
  For each item in banners.items of project.json:
    1. hueShift[] passes are applied to the ORIGINAL image  -> {{BG}}
    2. extract[] cuts light artwork (e.g. a third-party logo) out of the original -> {{EXTRACT:name}}
    3. the template (projects/<name>/banners/*.html, UTF-8) is wrapped with fonts + base CSS
    4. Chrome renders it at width x height; result saved into outputDir with the same name/format.

  Template placeholders:
    {{BG}} {{SRC}} {{LOGO_WHITE}} {{LOGO_COLOR}} {{EXTRACT:<name>}} {{NAME_AR}} {{NAME_EN}}
  Base CSS classes: .abs .neo .cai .lime .pill .center  (see $baseCss below)

.EXAMPLE
  .\tools\Render-Banners.ps1 -Project excp-swift-demo
  .\tools\Render-Banners.ps1 -Project excp-swift-demo -Only slider1.png
#>
param(
    [Parameter(Mandatory = $true)][string]$Project,
    [string]$Only
)
. (Join-Path $PSScriptRoot '_common.ps1')
Import-Recolor

$cfg = Get-RethemeConfig $Project
$src = $cfg._source; $dst = $cfg._output; $work = Join-Path $cfg._work 'banners'
if (-not (Test-Path $dst)) { throw "outputDir not found, run Invoke-Retheme.ps1 first: $dst" }
New-Item -ItemType Directory -Force $work | Out-Null

$chrome = $cfg.banners.chrome
if (-not $chrome) {
    $chrome = @("$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
                "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
                "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
                "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1
}
if (-not $chrome) { throw 'Chrome/Edge not found. Set banners.chrome in project.local.json' }

# fonts are embedded as base64 (file:// font loading is blocked by CORS in Chrome)
$fontCss = ''
foreach ($f in $cfg.banners.fonts.PSObject.Properties) {
    $fp = Resolve-ProjectPath $src $f.Value.file
    $b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($fp))
    $weight = if ($f.Value.weight) { ";font-weight:$($f.Value.weight)" } else { '' }
    $fontCss += "@font-face{font-family:$($f.Name);src:url(data:font/ttf;base64,$b64)$weight}`n"
}
$primary = $cfg.brand.primary; $secondary = $cfg.brand.secondary; $dark = $cfg.banners.darkColor
# accent / pill colors default to the secondary color (light secondary brands); override them when the secondary is dark
$accent   = if ($cfg.banners.accentColor)    { $cfg.banners.accentColor }    else { $secondary }
$pillBg   = if ($cfg.banners.pillBackground) { $cfg.banners.pillBackground } else { $secondary }
$pillText = if ($cfg.banners.pillText)       { $cfg.banners.pillText }       else { $dark }
$baseCss = @"
*{margin:0;padding:0;box-sizing:border-box}
html,body{overflow:hidden;background:#000}
.c{position:relative;overflow:hidden;direction:rtl}
.bg{position:absolute;left:0;top:0}
.abs{position:absolute}
.neo{font-family:Neo;color:#fff;line-height:1.15}
.cai{font-family:Cairo;color:#fff}
.lime{color:$accent}
.pill{display:inline-block;background:$pillBg;color:$pillText;font-family:Cairo;font-weight:800;padding:4px 22px 8px;border-radius:10px}
.center{left:0;right:0;text-align:center}
"@

$logoW = Get-FileUri (Resolve-ProjectPath $cfg._dir $cfg.brand.logoWhite)
$logoC = Get-FileUri (Resolve-ProjectPath $cfg._dir $cfg.brand.logoColor)

foreach ($b in @($cfg.banners.items)) {
    $rel = $b.file -replace '/', '\'; $name = Split-Path $rel -Leaf
    if ($Only -and $Only -ne $name) { continue }
    $orig = Join-Path $src $rel

    # 1) hue shift chain
    $bg = $orig; $i = 0
    foreach ($h in @($b.hueShift)) {
        if (-not $h) { continue }
        $next = Join-Path $work ("{0}.hue{1}.png" -f $name, $i++)
        $sat = if ($h.satMul) { [double]$h.satMul } else { 1.0 }
        [void][Recolor]::HueShift($bg, $next, [double]$h.from, [double]$h.to, [double]$h.soft, [double]$h.minSat, [double]$h.target, $sat)
        $bg = $next
    }
    # 2) extracts
    $html = [IO.File]::ReadAllText((Resolve-ProjectPath $cfg._dir $b.template), [Text.Encoding]::UTF8)
    foreach ($e in @($b.extract)) {
        if (-not $e) { continue }
        $ep = Join-Path $work ("{0}.{1}.png" -f $name, $e.name)
        [Recolor]::ExtractLight($orig, $ep, [int]$e.x, [int]$e.y, [int]$e.w, [int]$e.h, [int]$e.lo, [int]$e.hi)
        $html = $html.Replace("{{EXTRACT:$($e.name)}}", (Get-FileUri $ep))
    }
    # 3) placeholders + wrapper
    $html = $html.Replace('{{BG}}', (Get-FileUri $bg)).Replace('{{SRC}}', (Get-FileUri $orig))
    $html = $html.Replace('{{LOGO_WHITE}}', $logoW).Replace('{{LOGO_COLOR}}', $logoC)
    $html = $html.Replace('{{NAME_AR}}', $cfg.brand.nameAr).Replace('{{NAME_EN}}', $cfg.brand.nameEn)
    $html = $html.Replace('{{PRIMARY}}', $primary).Replace('{{SECONDARY}}', $secondary).Replace('{{DARK}}', $dark).Replace('{{ACCENT}}', $accent)
    $W = [int]$b.width; $H = [int]$b.height
    $page = "<!doctype html><html><head><meta charset='utf-8'><style>$fontCss$baseCss body{width:${W}px;height:${H}px} .c{width:${W}px;height:${H}px}</style></head>" +
            "<body><div class='c'><img class='bg' src='$(Get-FileUri $bg)' width='$W' height='$H'>$html</div></body></html>"
    $hp = Join-Path $work "$name.html"; Write-Utf8 $hp $page

    # 4) render
    $shot = Join-Path $work "$name.shot.png"; if (Test-Path $shot) { Remove-Item $shot }
    $cargs = @('--headless=new', '--disable-gpu', '--hide-scrollbars', '--force-device-scale-factor=1',
               "--user-data-dir=$work\chrome-profile", '--allow-file-access-from-files', '--virtual-time-budget=4000',
               "--window-size=$W,$H", "--screenshot=$shot", $hp)
    $ErrorActionPreference = 'Continue'; & $chrome @cargs 2>&1 | Out-Null; $ErrorActionPreference = 'Stop'
    if (-not (Test-Path $shot)) { throw "Chrome produced no screenshot for $name (see docs/troubleshooting.md)" }
    $out = Join-Path $dst $rel
    if ($rel -match '\.(jpe?g)$') {
        $q = if ($b.jpegQuality) { [long]$b.jpegQuality } else { 92 }
        [Recolor]::ToJpeg($shot, $out, $q)
    } else { Copy-Item $shot $out -Force }
    Write-Output ("Banner {0}: {1}" -f $rel, [Recolor]::Info($out))
}
