<#
.SYNOPSIS
  Builds a rebranded copy of an assets folder from a project config.

.DESCRIPTION
  Steps (all driven by projects/<name>/project.json):
    1. Copy sourceDir -> outputDir unchanged (same names, same structure).
    2. SVG: replace old brand hex colors (svg.colorMap + per-file svg.fileOverrides).
    3. Raster: recolor flat illustrations listed in raster.files (white-blend aware).
    4. Logos: write the new logo into the files listed in logos[].
  Banners are a separate step: tools/Render-Banners.ps1.
  The source folder is never modified.

.EXAMPLE
  .\tools\Invoke-Retheme.ps1 -Project excp-swift-demo
  .\tools\Invoke-Retheme.ps1 -Project excp-swift-demo -Force   # rebuild, deleting the old output
#>
param(
    [Parameter(Mandatory = $true)][string]$Project,
    [switch]$Force
)
. (Join-Path $PSScriptRoot '_common.ps1')
Import-Recolor

$cfg = Get-RethemeConfig $Project
Assert-BrandFonts $cfg
$src = $cfg._source; $dst = $cfg._output
if (-not (Test-Path $src)) { throw "sourceDir not found: $src (set it in project.local.json)" }
if ($src.TrimEnd('\') -ieq $dst.TrimEnd('\')) { throw 'outputDir must differ from sourceDir' }
New-Item -ItemType Directory -Force $cfg._work | Out-Null

# 1) copy
if (Test-Path $dst) {
    if (-not $Force) { throw "outputDir already exists: $dst (use -Force to rebuild)" }
    Remove-Item -Recurse -Force $dst -Confirm:$false
}
Copy-Item -Path $src -Destination $dst -Recurse
Write-Output "[1/4] Copied $((Get-ChildItem $dst -Recurse -File).Count) files -> $dst"

# 2) SVG colors
$baseMap = ConvertTo-ColorMap $cfg.svg.colorMap
$skip = @(); if ($cfg.svg.skip) { $skip = @($cfg.svg.skip | ForEach-Object { $_ -replace '/', '\' }) }
$overrides = @{}
if ($cfg.svg.fileOverrides) { foreach ($p in $cfg.svg.fileOverrides.PSObject.Properties) { $overrides[($p.Name -replace '/', '\')] = ConvertTo-ColorMap $p.Value } }
$svgChanged = 0
Get-ChildItem $dst -Recurse -Filter *.svg | ForEach-Object {
    $rel = $_.FullName.Substring($dst.Length).TrimStart('\')
    if ($skip -contains $rel) { return }
    $m = [ordered]@{}; foreach ($k in $baseMap.Keys) { $m[$k] = $baseMap[$k] }
    if ($overrides.ContainsKey($rel)) { foreach ($k in $overrides[$rel].Keys) { $m[$k] = $overrides[$rel][$k] } }
    if ($m.Count -eq 0) { return }
    $text = [IO.File]::ReadAllText($_.FullName)
    $pattern = '#(' + (@($m.Keys) -join '|') + ')(?![0-9A-Fa-f])'
    $new = [regex]::Replace($text, $pattern, { param($x) '#' + $m[$x.Groups[1].Value.ToUpper()].ToLower() }, 'IgnoreCase')
    if ($new -ne $text) { Write-Utf8 $_.FullName $new; $svgChanged++ }
}
Write-Output "[2/4] SVG files recolored: $svgChanged"

# 3) raster illustrations
$rMap = ConvertTo-ColorMap $cfg.raster.colorMap
$tol = if ($cfg.raster.tolerance) { [double]$cfg.raster.tolerance } else { 20 }
foreach ($f in @($cfg.raster.files)) {
    if (-not $f) { continue }
    $rel = $f -replace '/', '\'
    $n = [Recolor]::Apply((Join-Path $src $rel), (Join-Path $dst $rel), [string[]]@($rMap.Keys), [string[]]@($rMap.Values), $tol)
    Write-Output ("[3/4] Raster {0}: {1} px" -f $rel, $n)
}

# 4) logos
function Get-LogoPath($which) {
    $key = if ($which -eq 'white') { 'logoWhite' } else { 'logoColor' }
    $p = Resolve-ProjectPath $cfg._dir $cfg.brand.$key
    if (-not (Test-Path $p)) { throw "Logo file missing: $p (brand/ is git-ignored, copy it in first)" }
    return $p
}
foreach ($l in @($cfg.logos)) {
    if (-not $l) { continue }
    $rel = $l.file -replace '/', '\'; $out = Join-Path $dst $rel
    $logo = Get-LogoPath $l.logo
    if ($l.whiteText) {
        # turn the wordmark (everything right of the first wide transparent gap) white, keep the symbol colors
        $gap = [Recolor]::FindGap($logo, [int]$l.textGap)
        if ($gap -lt 0) { throw "No gap found in $logo for whiteText" }
        $tmp = Join-Path $cfg._work ('whitetext_' + [IO.Path]::GetFileNameWithoutExtension($rel) + '.png')
        [Recolor]::WhiteFrom($logo, $tmp, $gap); $logo = $tmp
    }
    if ($l.type -eq 'png-canvas') {
        $d = [Recolor]::Canvas($logo, $out, [int]$l.width, [int]$l.height, [double]$l.fill)
        Write-Output "[4/4] Logo $rel : png $($l.width)x$($l.height), logo drawn $d"
    }
    elseif ($l.type -eq 'svg-embed') {
        $scale = if ($l.renderScale) { [int]$l.renderScale } else { 4 }
        $png = Join-Path $cfg._work ('embed_' + [IO.Path]::GetFileNameWithoutExtension($rel) + '.png')
        $d = [Recolor]::Canvas($logo, $png, [int]$l.width * $scale, [int]$l.height * $scale, [double]$l.fill)
        $b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($png))
        $svg = "<svg xmlns=`"http://www.w3.org/2000/svg`" xmlns:xlink=`"http://www.w3.org/1999/xlink`" width=`"$($l.width)`" height=`"$($l.height)`" viewBox=`"0 0 $($l.width) $($l.height)`">`n  <image width=`"$($l.width)`" height=`"$($l.height)`" xlink:href=`"data:image/png;base64,$b64`"/>`n</svg>`n"
        Write-Utf8 $out $svg
        Write-Output "[4/4] Logo $rel : svg $($l.width)x$($l.height) (embedded png x$scale, logo drawn $d)"
    }
    elseif ($l.type -eq 'svg-vector') {
        # keep the logo as vectors: nest the client's SVG (cropped to l.viewBox) centered in the original canvas
        $srcSvg = Resolve-ProjectPath $cfg._dir $l.source
        $t = [IO.File]::ReadAllText($srcSvg, [Text.Encoding]::UTF8)
        $open = [regex]::Match($t, '<svg\b[^>]*>'); $close = $t.LastIndexOf('</svg>')
        if (-not $open.Success -or $close -lt 0) { throw "Not an SVG: $srcSvg" }
        $inner = $t.Substring($open.Index + $open.Length, $close - $open.Index - $open.Length)
        $vb = if ($l.viewBox) { $l.viewBox } else { [regex]::Match($open.Value, 'viewBox="([^"]+)"').Groups[1].Value }
        $W = [double]$l.width; $H = [double]$l.height; $f = [double]$l.fill
        $iw = $W * $f; $ih = $H * $f; $ix = ($W - $iw) / 2; $iy = ($H - $ih) / 2
        $ci = [Globalization.CultureInfo]::InvariantCulture
        $svg = [string]::Format($ci, "<svg xmlns=`"http://www.w3.org/2000/svg`" xmlns:xlink=`"http://www.w3.org/1999/xlink`" width=`"{0}`" height=`"{1}`" viewBox=`"0 0 {0} {1}`">`n<svg x=`"{2:0.##}`" y=`"{3:0.##}`" width=`"{4:0.##}`" height=`"{5:0.##}`" viewBox=`"{6}`" preserveAspectRatio=`"xMidYMid meet`">{7}</svg>`n</svg>`n",
            $l.width, $l.height, $ix, $iy, $iw, $ih, $vb, $inner)
        Write-Utf8 $out $svg
        Write-Output "[4/4] Logo $rel : vector svg $($l.width)x$($l.height) from $($l.source) (viewBox $vb)"
    }
    else { throw "Unknown logo type '$($l.type)' for $rel" }
}

# 5) added files (explicit exception to "same files as the source", see docs/decisions/0017-deliver-brand-fonts-in-assets.md)
foreach ($a in @($cfg.addFiles)) {
    if (-not $a) { continue }
    $from = Resolve-ProjectPath $cfg._dir $a.from
    if (-not (Test-Path $from)) { throw "addFiles source missing: $from (brand/ is git-ignored, copy it in first)" }
    $to = Join-Path $dst ($a.to -replace '/', '\')
    if (Test-Path $to) { throw "addFiles target already exists in the source assets: $($a.to) (addFiles never overwrites)" }
    New-Item -ItemType Directory -Force (Split-Path -Parent $to) | Out-Null
    Copy-Item $from $to
    Write-Output "[5/5] Added $($a.to)"
}
Write-Output "Done. Next: tools\Render-Banners.ps1 -Project $Project, then tools\Compare-Assets.ps1 -Project $Project"
