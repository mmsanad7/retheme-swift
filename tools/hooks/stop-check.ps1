# stop-check.ps1 - Claude Code Stop hook (.claude/settings.json).
# Blocks ending the turn while there are uncommitted or unpushed changes (rule: push after any change).
# Keep this file ASCII-only.

$payload = [Console]::In.ReadToEnd()
try { $data = $payload | ConvertFrom-Json } catch { $data = $null }
if ($data -and $data.stop_hook_active) { exit 0 }   # already reminded once; avoid loops

$repo = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Push-Location $repo
try {
    $dirty = @(git status --porcelain)
    git fetch --quiet 2>$null
    $ahead = git rev-list --count '@{u}..HEAD' 2>$null
    $problems = @()
    if ($dirty.Count) { $problems += "$($dirty.Count) uncommitted change(s)" }
    if ($ahead -and [int]$ahead -gt 0) { $problems += "$ahead unpushed commit(s)" }
    if ($problems.Count) {
        [Console]::Error.WriteLine("Repo rule: push after any change. Found: $($problems -join ', '). " +
            "git pull, then commit (Conventional Commits) and git push - or tell the user why it must wait.")
        exit 2
    }
}
finally { Pop-Location }
exit 0
