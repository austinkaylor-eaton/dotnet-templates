# add-gitkeep-to-every-repo-folder.ps1
# Adds .gitkeep files to every repository directory and subdirectory.
# Excludes .git and .idea directories (and all their subdirectories).
# Useful for maintaining empty folder structures in Git.
#
# Usage:
#   .\add-gitkeep-to-every-repo-folder.ps1
#   .\add-gitkeep-to-every-repo-folder.ps1 -WhatIf
#   .\add-gitkeep-to-every-repo-folder.ps1 -Confirm

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'shared.ps1')

# ---------------------------------------------------------------------------

Write-Banner 'Add .gitkeep to Repository Directories'

$repoRoot = Get-RepoRoot
Write-Info "Repository root: $repoRoot"

$created  = 0
$existing = 0
$excluded = 0

# Get all directories under repo root, excluding root itself
$allDirs = Get-ChildItem -Path $repoRoot -Recurse -Directory -ErrorAction SilentlyContinue

# Filter out excluded paths (.git and .idea, plus all their descendants)
$targetDirs = $allDirs | Where-Object {
    $relativePath = $_.FullName.Substring($repoRoot.Length).TrimStart('\')
    -not ($relativePath -like '.git*' -or $relativePath -like '.idea*')
}

Write-Step "Processing $($targetDirs.Count) directories"

foreach ($dir in $targetDirs) {
    $gitkeepPath = Join-Path $dir.FullName '.gitkeep'
    $relativePath = $dir.FullName.Substring($repoRoot.Length).TrimStart('\')

    if (Test-Path $gitkeepPath) {
        Write-Info "  [EXISTS] $relativePath"
        $existing++
    }
    else {
        if ($PSCmdlet.ShouldProcess($relativePath, 'Create .gitkeep')) {
            New-Item -ItemType File -Path $gitkeepPath -Force | Out-Null
            Write-Success "  [CREATED] $relativePath"
            $created++
        }
    }
}

# Count excluded directories
$excludedDirs = $allDirs | Where-Object {
    $relativePath = $_.FullName.Substring($repoRoot.Length).TrimStart('\')
    $relativePath -like '.git*' -or $relativePath -like '.idea*'
}
$excluded = $excludedDirs.Count

# ---------------------------------------------------------------------------

Write-Banner 'Summary'

Write-Host "  Created  : $created" -ForegroundColor Green
Write-Host "  Existing : $existing" -ForegroundColor Cyan
Write-Host "  Excluded : $excluded" -ForegroundColor Yellow

Write-Host ''

