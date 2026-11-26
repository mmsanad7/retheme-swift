<#
.SYNOPSIS
  Starts a new client project: config, workspace folders and documentation, in one step.

.DESCRIPTION
  (docs/decisions/0018-workspace-layout-and-project-scaffold.md)
    1. projects/<name>/project.json from projects/_template, filled with the brand values.
    2. projects/<name>/brand/ (git-ignored) and <root>/clients/<name>/ on this machine.
    3. docs/projects/<name>/README.md and handoff.md from docs/projects/_template.
    4. A row in memory/project-log.md and in the projects table of README.md.
  Brand fonts are required up front (ADR 0016). Arabic text comes from the UTF-8
  templates in docs/projects/_template, so this script stays ASCII-only.

.EXAMPLE
  .\tools\New-Project.ps1 -Name acme -NameAr "<arabic name>" -NameEn "Acme" -Primary "#123456" -Secondary "#ABCDEF" `
      -FontAr Kufam -FontArSource https://fonts.google.com/specimen/Kufam `
      -FontEn Montserrat -FontEnSource https://fonts.google.com/specimen/Montserrat
#>
param(
    [Parameter(Mandatory = $true)][ValidatePattern('^[a-z0-9]+(-[a-z0-9]+)*$')][string]$Name,
    [Parameter(Mandatory = $true)][string]$NameAr,
    [Parameter(Mandatory = $true)][string]$NameEn,
    [Parameter(Mandatory = $true)][ValidatePattern('^#[0-9A-Fa-f]{6}$')][string]$Primary,
    [Parameter(Mandatory = $true)][ValidatePattern('^#[0-9A-Fa-f]{6}$')][string]$Secondary,
    [Parameter(Mandatory = $true)][string]$FontAr,
    [Parameter(Mandatory = $true)][string]$FontArSource,
    [Parameter(Mandatory = $true)][string]$FontEn,
    [Parameter(Mandatory = $true)][string]$FontEnSource,
    [string]$BaseApp = 'aber-alqarat',
    [string]$OutputName        # default: assets.<name>
)
. (Join-Path $PSScriptRoot '_common.ps1')

$root = Get-WorkspaceRoot
if (-not $OutputName) { $OutputName = "assets.$Name" }
$projDir = Join-Path $script:RepoRoot "projects\$Name"
$docsDir = Join-Path $script:RepoRoot "docs\projects\$Name"
$tplDocs = Join-Path $script:RepoRoot 'docs\projects\_template'
foreach ($d in $projDir, $docsDir) { if (Test-Path $d) { throw "Project already exists: $d" } }

$values = [ordered]@{
    NAME = $Name; NAME_AR = $NameAr; NAME_EN = $NameEn; PRIMARY = $Primary.ToUpper(); SECONDARY = $Secondary.ToUpper()
    BASE_APP = $BaseApp; OUTPUT_NAME = $OutputName; DATE = (Get-Date -Format 'yyyy-MM-dd')
}
function Expand-Template([string]$Text) {
    foreach ($k in $values.Keys) { $Text = $Text.Replace("{{$k}}", $values[$k]) }
    return $Text
}
function Read-Utf8([string]$Path) { [IO.File]::ReadAllText($Path, [Text.Encoding]::UTF8) }
# JSON string literal content (quotes and backslashes escaped)
function Format-JsonText([string]$s) { $s.Replace('\', '\\').Replace('"', '\"') }
function Set-JsonValue([string]$Json, [string]$Key, [string]$Value) {
    $rx = New-Object Text.RegularExpressions.Regex ('("' + $Key + '"\s*:\s*)"[^"]*"')
    if (-not $rx.IsMatch($Json)) { throw "Template project.json has no '$Key'" }
    return $rx.Replace($Json, { param($m) $m.Groups[1].Value + '"' + (Format-JsonText $Value) + '"' }, 1)
}

# 1) project.json
New-Item -ItemType Directory -Force (Join-Path $projDir 'brand') | Out-Null
Copy-Item (Join-Path $script:RepoRoot 'projects\_template\*') $projDir -Recurse
$json = Read-Utf8 (Join-Path $projDir 'project.json')
$json = Set-JsonValue $json 'name' $Name
$json = Set-JsonValue $json 'description' "Retheme of the '$BaseApp' app assets to $NameEn"
$json = Set-JsonValue $json 'baseApp' $BaseApp
$json = Set-JsonValue $json 'sourceDir' "{root}/base-assets/$BaseApp"
$json = Set-JsonValue $json 'outputDir' "{root}/clients/$Name/$OutputName"
$json = Set-JsonValue $json 'nameAr' $NameAr
$json = Set-JsonValue $json 'nameEn' $NameEn
$json = Set-JsonValue $json 'primary' $values.PRIMARY
$json = Set-JsonValue $json 'secondary' $values.SECONDARY
# brand.fonts: ar comes first in the template, then en
$fontRx = New-Object Text.RegularExpressions.Regex '("(ar|en)"\s*:\s*\{\s*"family"\s*:\s*)"[^"]*"(\s*,\s*"source"\s*:\s*)"[^"]*"'
$json = $fontRx.Replace($json, {
    param($m)
    $f = if ($m.Groups[2].Value -eq 'ar') { $FontAr, $FontArSource } else { $FontEn, $FontEnSource }
    $m.Groups[1].Value + '"' + (Format-JsonText $f[0]) + '"' + $m.Groups[3].Value + '"' + (Format-JsonText $f[1]) + '"'
})
Write-Utf8 (Join-Path $projDir 'project.json') $json
$null = Read-Utf8Json (Join-Path $projDir 'project.json')   # fail early if the result is not valid JSON

# 2) workspace folder for the output
New-Item -ItemType Directory -Force (Join-Path $root "clients\$Name") | Out-Null

# 3) docs
foreach ($f in 'README.md', 'handoff.md') {
    Write-Utf8 (Join-Path $docsDir $f) (Expand-Template (Read-Utf8 (Join-Path $tplDocs $f)))
}

# 4) index rows: project log (before the open-items section) and the README projects table
$rows = Read-Utf8Json (Join-Path $tplDocs 'index-rows.json')
function Add-AfterLastTableRow([string]$Path, [string]$StartPattern, [string]$EndPattern, [string]$Row) {
    $lines = [Collections.Generic.List[string]](Read-Utf8 $Path).Replace("`r`n", "`n").Split("`n")
    $start = -1; $last = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($start -lt 0) {
            if ($lines[$i] -match $StartPattern) { $start = $i; if ($lines[$i].StartsWith('|')) { $last = $i } }
            continue
        }
        if ($lines[$i] -match $EndPattern) { break }
        if ($lines[$i].StartsWith('|')) { $last = $i }
    }
    if ($last -lt 0) { throw "Table not found in $Path" }
    $lines.Insert($last + 1, $Row)
    Write-Utf8 $Path ($lines -join "`n")
}
Add-AfterLastTableRow (Join-Path $script:RepoRoot 'memory\project-log.md') '^# ' '^## ' (Expand-Template $rows.logRow)
Add-AfterLastTableRow (Join-Path $script:RepoRoot 'README.md') '^\| `' '^## ' (Expand-Template $rows.readmeRow)

Write-Host "Project '$Name' created:" -ForegroundColor Green
Write-Host "  config : projects\$Name\project.json"
Write-Host "  docs   : docs\projects\$Name\README.md, handoff.md"
Write-Host "  output : $root\clients\$Name\$OutputName (written by Invoke-Retheme)"
Write-Host 'Next:'
Write-Host "  - put the logo (logo-color.png / logo-white.png or an SVG) and the font files in projects\$Name\brand\"
$base = Join-Path $root "base-assets\$BaseApp"
if (-not (Test-Path $base)) { Write-Host "  - base assets missing: copy the original '$BaseApp' assets into $base" -ForegroundColor Yellow }
Write-Host '  - follow docs\workflow.md from step 1 (color analysis)'
