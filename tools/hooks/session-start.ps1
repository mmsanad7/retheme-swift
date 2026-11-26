# session-start.ps1 - Claude Code SessionStart hook (.claude/settings.json).
# Pulls the latest version, activates the git hooks, and reminds Claude of the binding rules.
# Keep this file ASCII-only.

$repo = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Push-Location $repo
try {
    git config core.hooksPath .githooks
    $pull = git pull --ff-only 2>&1 | Out-String
    $ok = $LASTEXITCODE -eq 0
    Write-Output "[retheme-swift] git pull: $(if ($ok) { 'OK' } else { 'FAILED' })"
    Write-Output $pull.Trim()
    if (-not $ok) { Write-Output "Pull failed: resolve it (and tell the user) before editing anything." }
    Write-Output "Binding rules: CLAUDE.md + docs/decisions/ (all ADRs) + memory/. Pull before any change, commit and push after. File names in replies must be links."
}
finally { Pop-Location }
exit 0
