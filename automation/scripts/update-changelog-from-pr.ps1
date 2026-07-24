<#
.SYNOPSIS
    Extracts changelog entries from PR body and updates CHANGELOG.md

.DESCRIPTION
    This script parses the PR body for changelog sections marked with
    <!-- CHANGELOG_START -->SectionName<!-- CHANGELOG_END --> markers
    and appends them to the "Unreleased" section of CHANGELOG.md

.PARAMETER PrBody
    The full body text of the pull request

.PARAMETER PrNumber
    The pull request number (for logging)

.EXAMPLE
    .\update-changelog-from-pr.ps1 -PrBody $prBodyText -PrNumber 42
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$PrBody,

    [Parameter(Mandatory = $false)]
    [int]$PrNumber = 0
)

$ChangelogPath = "CHANGELOG.md"
$Sections = @("Added", "Changed", "Fixed", "Removed")
$ExtractedChanges = @{}

# Extract changelog sections from PR body
foreach ($section in $Sections) {
    $pattern = "### <!-- CHANGELOG_START -->$section<!-- CHANGELOG_END -->`r?`n([\s\S]*?)(?=###|$)"

    if ($PrBody -match $pattern) {
        $content = $matches[1].Trim()

        # Extract bullet points, filtering out empty lines and instructions
        $lines = @($content -split "`n" | Where-Object {
            $_.Trim() -match "^-\s+" -and $_.Trim() -ne "-"
        })

        if ($lines.Count -gt 0) {
            $ExtractedChanges[$section] = $lines
        }
    }
}

# Exit early if no changelog entries found
if ($ExtractedChanges.Count -eq 0) {
    Write-Host "ℹ️  No changelog entries found in PR body. Skipping changelog update."
    exit 0
}

Write-Host "📝 Extracted changelog entries:"
foreach ($section in $ExtractedChanges.Keys) {
    Write-Host "  [$section]"
    foreach ($line in $ExtractedChanges[$section]) {
        Write-Host "    $line"
    }
}

# Read current changelog
$changelogContent = Get-Content $ChangelogPath -Raw

# Find the "## Unreleased" section and insert changes there
$unreleasePattern = "(## Unreleased\s*\n)"

if ($changelogContent -match $unreleasePattern) {
    # Build the new entries section
    $newEntries = ""
    foreach ($section in $Sections) {
        if ($ExtractedChanges.ContainsKey($section)) {
            $newEntries += "`n### $section`n"
            foreach ($line in $ExtractedChanges[$section]) {
                $newEntries += "$line`n"
            }
        }
    }

    # Replace the unreleased section with updated content
    $updatedContent = $changelogContent -replace $unreleasePattern, "`$1`n$($newEntries.TrimStart())"

    # Write updated changelog
    Set-Content $ChangelogPath -Value $updatedContent -NoNewline

    Write-Host "✅ Successfully updated CHANGELOG.md"
} else {
    Write-Host "⚠️  Warning: 'Unreleased' section not found in CHANGELOG.md. Skipping update."
    exit 1
}

