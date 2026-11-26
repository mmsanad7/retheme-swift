# Test-RepoRules.ps1 - enforces the repo rules (docs/decisions/0015-binding-rules-enforced.md).
# Used by the git pre-commit hook (-Staged) and by CI (all tracked files).
# Keep this file ASCII-only (see docs/troubleshooting.md).

param(
    [switch]$Staged   # check staged files only (pre-commit); default = all tracked files
)

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
Push-Location $repo
try {
    $files = if ($Staged) { git diff --cached --name-only --diff-filter=ACMR } else { git ls-files }
    $files = @($files | Where-Object { $_ })
    $errors = New-Object System.Collections.Generic.List[string]

    # Rule: client files never go to git (ADR 0001). _template is ours, not a client's.
    $clientPattern = '^projects/[^/]+/(brand|input|output|\.work)/|^projects/[^/]+/project\.local\.json$|^projects/.+\.(png|jpe?g|webp|gif|svg|ttf|otf|zip|rar)$'
    foreach ($f in $files) {
        if ($f -match $clientPattern) { $errors.Add("client file must not be committed: $f (ADR 0001)") }
    }

    # Rule: .ps1 files are ASCII-only (PowerShell 5.1 reads BOM-less scripts as ANSI).
    foreach ($f in $files | Where-Object { $_ -like '*.ps1' }) {
        $bytes = if ($Staged) {
            $tmp = [IO.Path]::GetTempFileName()
            Start-Process git -ArgumentList 'show', ":$f" -RedirectStandardOutput $tmp -NoNewWindow -Wait
            $b = [IO.File]::ReadAllBytes($tmp); Remove-Item $tmp; $b
        } else { [IO.File]::ReadAllBytes((Join-Path $repo $f)) }
        if ($bytes | Where-Object { $_ -gt 127 } | Select-Object -First 1) {
            $errors.Add("non-ASCII characters in script: $f (CLAUDE.md rule 6)")
        }
    }

    if ($errors.Count) {
        Write-Host "Repo rules check FAILED:" -ForegroundColor Red
        $errors | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
        Write-Host "Rules: docs/decisions/0015-binding-rules-enforced.md"
        exit 1
    }
    Write-Host "Repo rules check passed ($($files.Count) files)."
}
finally { Pop-Location }
