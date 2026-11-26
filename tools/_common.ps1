# _common.ps1 - shared helpers, dot-sourced by the other tools.
# Keep this file ASCII-only: Windows PowerShell 5.1 reads BOM-less scripts as ANSI
# (see docs/troubleshooting.md). Arabic text lives in JSON/HTML files read as UTF-8.

$ErrorActionPreference = 'Stop'
$script:RepoRoot = Split-Path -Parent $PSScriptRoot
$script:Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

# Activate the repo git hooks on first use of any tool (docs/decisions/0015-binding-rules-enforced.md).
if ((git -C $script:RepoRoot config core.hooksPath 2>$null) -ne '.githooks') {
    git -C $script:RepoRoot config core.hooksPath .githooks 2>$null
}

function Import-Recolor {
    if (-not ('Recolor' -as [type])) {
        Add-Type -Path (Join-Path $PSScriptRoot 'Recolor.cs') -ReferencedAssemblies System.Drawing
    }
}

function Read-Utf8Json([string]$Path) {
    [IO.File]::ReadAllText($Path, [Text.Encoding]::UTF8) | ConvertFrom-Json
}

function Write-Utf8([string]$Path, [string]$Text) {
    $dir = Split-Path -Parent $Path
    if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Force $dir | Out-Null }
    [IO.File]::WriteAllText($Path, $Text, $script:Utf8NoBom)
}

# Resolve a path from the config: absolute paths stay, relative ones are relative to the project folder.
function Resolve-ProjectPath([string]$ProjectDir, [string]$Path) {
    if ([string]::IsNullOrWhiteSpace($Path)) { return $null }
    $p = $Path -replace '/', '\'
    if ([IO.Path]::IsPathRooted($p)) { return $p }
    return [IO.Path]::GetFullPath((Join-Path $ProjectDir $p))
}

# Loads projects/<name>/project.json and shallow-merges project.local.json (git-ignored, per machine).
function Get-RethemeConfig([string]$Project) {
    $dir = if (Test-Path $Project -PathType Container) { (Resolve-Path $Project).Path }
           else { Join-Path $script:RepoRoot "projects\$Project" }
    $main = Join-Path $dir 'project.json'
    if (-not (Test-Path $main)) { throw "project.json not found in $dir" }
    $cfg = Read-Utf8Json $main
    $local = Join-Path $dir 'project.local.json'
    if (Test-Path $local) {
        $over = Read-Utf8Json $local
        foreach ($p in $over.PSObject.Properties) { $cfg | Add-Member -NotePropertyName $p.Name -NotePropertyValue $p.Value -Force }
    }
    $cfg | Add-Member -NotePropertyName '_dir' -NotePropertyValue $dir -Force
    $cfg | Add-Member -NotePropertyName '_source' -NotePropertyValue (Resolve-ProjectPath $dir $cfg.sourceDir) -Force
    $cfg | Add-Member -NotePropertyName '_output' -NotePropertyValue (Resolve-ProjectPath $dir $cfg.outputDir) -Force
    $cfg | Add-Member -NotePropertyName '_work' -NotePropertyValue (Join-Path $dir '.work') -Force
    return $cfg
}

# Brand fonts are mandatory (docs/decisions/0016-brand-fonts-mandatory.md): returns the list of problems.
# -Banners also requires every banner font to be a brand font file (brandFile), not an app font.
function Get-BrandFontProblems($cfg, [switch]$Banners) {
    if ($cfg.legacyNoBrandFonts) { return @() }
    $p = @()
    foreach ($lang in 'ar', 'en') {
        $f = $cfg.brand.fonts.$lang
        if (-not $f -or -not $f.family -or -not $f.source) { $p += "brand.fonts.$lang (family + source) is missing" }
    }
    if ($Banners -and $cfg.banners) {
        foreach ($f in $cfg.banners.fonts.PSObject.Properties) {
            if (-not $f.Value.brandFile) { $p += "banners.fonts.$($f.Name) uses an app font ('file'); banners must use the brand font ('brandFile')" }
        }
    }
    return $p
}

function Assert-BrandFonts($cfg, [switch]$Banners) {
    $p = @(Get-BrandFontProblems $cfg -Banners:$Banners)
    if ($p.Count) { throw ("Brand fonts rule (ADR 0016) - {0}: {1}" -f $cfg.name, ($p -join '; ')) }
}

# PSCustomObject -> ordered hashtable with upper-case hex keys (no '#').
function ConvertTo-ColorMap($obj) {
    $m = [ordered]@{}
    if ($null -eq $obj) { return $m }
    foreach ($p in $obj.PSObject.Properties) { $m[$p.Name.TrimStart('#').ToUpper()] = $p.Value.TrimStart('#').ToUpper() }
    return $m
}

function Get-FileUri([string]$Path) { 'file:///' + ($Path -replace '\\', '/') }
