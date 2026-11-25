<#
.SYNOPSIS
  Step 1 of a new project: find which colors the assets use and where the old brand colors are.

.DESCRIPTION
  - Lists every hex color used in SVGs with its count and the files using it.
  - For each raster (png/jpg), counts pixels close to the given old brand colors
    (white-blend aware, same matcher as the recolor step).
  Use the output to fill svg.colorMap / raster.files in project.json.

.EXAMPLE
  .\tools\Get-ColorReport.ps1 -Source D:\client\assets -OldBrand 224182,1BAAE2,12AAE3,8DC43E
  .\tools\Get-ColorReport.ps1 -Project excp-swift-demo -OldBrand 224182,1BAAE2 -OutFile .work\colors.md
#>
param(
    [string]$Project,
    [string]$Source,
    [string[]]$OldBrand = @(),
    [int]$Top = 60,
    [double]$Tolerance = 20,
    [string]$OutFile
)
. (Join-Path $PSScriptRoot '_common.ps1')
Import-Recolor
if ($Project) { $Source = (Get-RethemeConfig $Project)._source }
if (-not $Source -or -not (Test-Path $Source)) { throw 'Give -Source <assets folder> or -Project <name>' }
$Source = (Resolve-Path $Source).Path

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Color report"); $lines.Add(''); $lines.Add("Source: ``$Source``"); $lines.Add('')

# SVG colors
$byColor = @{}
Get-ChildItem $Source -Recurse -Filter *.svg | ForEach-Object {
    $rel = $_.FullName.Substring($Source.Length).TrimStart('\') -replace '\\', '/'
    $t = [IO.File]::ReadAllText($_.FullName)
    foreach ($m in [regex]::Matches($t, '#([0-9a-fA-F]{6}|[0-9a-fA-F]{3})(?![0-9a-fA-F])')) {
        $c = $m.Groups[1].Value.ToUpper()
        if (-not $byColor.ContainsKey($c)) { $byColor[$c] = @{ n = 0; files = New-Object System.Collections.Generic.HashSet[string] } }
        $byColor[$c].n++; [void]$byColor[$c].files.Add($rel)
    }
}
$lines.Add("## SVG colors (top $Top)"); $lines.Add(''); $lines.Add('| Color | Uses | Files | Example files |'); $lines.Add('|---|---|---|---|')
$byColor.GetEnumerator() | Sort-Object { $_.Value.n } -Descending | Select-Object -First $Top | ForEach-Object {
    $ex = (@($_.Value.files) | Select-Object -First 3) -join ', '
    $lines.Add("| #$($_.Key) | $($_.Value.n) | $($_.Value.files.Count) | $ex |")
}

# Rasters
if ($OldBrand.Count) {
    $ob = [string[]]@($OldBrand | ForEach-Object { $_.TrimStart('#').ToUpper() })
    $lines.Add(''); $lines.Add("## Rasters vs old brand ($($ob -join ', '))"); $lines.Add('')
    $lines.Add('> High counts on a flat illustration = recolor candidate. Photos need the banner step instead.'); $lines.Add('')
    Get-ChildItem $Source -Recurse -Include *.png, *.jpg, *.jpeg | ForEach-Object {
        $rel = $_.FullName.Substring($Source.Length).TrimStart('\') -replace '\\', '/'
        $lines.Add("- ``$rel`` : " + [Recolor]::Analyze($_.FullName, $ob, $Tolerance))
    }
}
$text = $lines -join "`n"
if ($OutFile) { Write-Utf8 ([IO.Path]::GetFullPath((Join-Path (Get-Location) $OutFile))) $text; Write-Output "Report written: $OutFile" }
else { $text }
