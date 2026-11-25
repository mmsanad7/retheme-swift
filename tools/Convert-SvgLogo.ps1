<#
.SYNOPSIS
  Turns a client SVG logo into the brand/ PNGs the other tools use (transparent, trimmed, high-res),
  and optionally a white version (every fill/stroke color -> #FFFFFF).

.EXAMPLE
  .\tools\Convert-SvgLogo.ps1 -Svg brand\logo-ar.svg -Out brand\logo-color.png
  .\tools\Convert-SvgLogo.ps1 -Svg brand\logo-ar.svg -Out brand\logo-white.png -White -WhiteSvgOut brand\logo-white.svg
#>
param(
    [Parameter(Mandatory = $true)][string]$Svg,
    [Parameter(Mandatory = $true)][string]$Out,
    [int]$Size = 2000,
    [int]$Margin = 4,
    [switch]$White,
    [string]$WhiteSvgOut,
    [string]$Chrome
)
. (Join-Path $PSScriptRoot '_common.ps1')
Import-Recolor
$Svg = (Resolve-Path $Svg).Path
$Out = [IO.Path]::GetFullPath((Join-Path (Get-Location) $Out))
if (-not $Chrome) {
    $Chrome = @("$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
                "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
                "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1
}
$work = Join-Path ([IO.Path]::GetTempPath()) ('svglogo_' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force $work | Out-Null

$text = [IO.File]::ReadAllText($Svg, [Text.Encoding]::UTF8)
if ($White) {
    # recolor every explicit color (fill/stroke attributes and style declarations); keep 'none'
    $text = [regex]::Replace($text, '(fill|stroke)(\s*[:=]\s*"?)\s*(#[0-9a-fA-F]{3,8}|rgba?\([^)]*\)|black|white)', '$1$2#FFFFFF')
    if ($WhiteSvgOut) { Write-Utf8 ([IO.Path]::GetFullPath((Join-Path (Get-Location) $WhiteSvgOut))) $text; Write-Output "White SVG: $WhiteSvgOut" }
}
$svgFile = Join-Path $work 'logo.svg'; Write-Utf8 $svgFile $text
$html = "<!doctype html><html><head><meta charset='utf-8'><style>html,body{margin:0;background:transparent;overflow:hidden}img{display:block;width:${Size}px;height:${Size}px;object-fit:contain}</style></head><body><img src='$(Get-FileUri $svgFile)'></body></html>"
$page = Join-Path $work 'page.html'; Write-Utf8 $page $html
$shot = Join-Path $work 'shot.png'
$cargs = @('--headless=new', '--disable-gpu', '--hide-scrollbars', '--force-device-scale-factor=1', '--default-background-color=00000000',
           "--user-data-dir=$work\profile", '--allow-file-access-from-files', '--virtual-time-budget=3000',
           "--window-size=$Size,$Size", "--screenshot=$shot", $page)
$ErrorActionPreference = 'Continue'; & $Chrome @cargs 2>&1 | Out-Null; $ErrorActionPreference = 'Stop'
if (-not (Test-Path $shot)) { throw 'Chrome produced no screenshot' }
$box = [Recolor]::Trim($shot, $Out, $Margin)
Write-Output ("{0}: {1}  (content box in {2}px render: {3})" -f $Out, [Recolor]::Info($Out), $Size, $box)
Remove-Item -Recurse -Force $work -Confirm:$false -ErrorAction SilentlyContinue
