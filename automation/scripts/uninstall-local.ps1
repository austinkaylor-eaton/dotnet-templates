# uninstall-local.ps1
# Removes all templates in this repository from the local dotnet template cache.
# Use this to clean up after local testing or before re-installing.
#
# Usage:
#   .\uninstall-local.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'shared.ps1')

# ---------------------------------------------------------------------------

Write-Banner 'Uninstall Templates Locally'

$templates = Get-AllTemplates

if ($templates.Count -eq 0) {
    Write-Warn 'No templates found in repository.'
    exit 0
}

$passed  = 0
$failed  = 0
$results = @()

foreach ($template in $templates) {
    Write-Step "Uninstalling '$($template.Identity)'"
    Write-Info "Source: $($template.SrcPath)"

    & dotnet new uninstall $template.SrcPath 2>&1 | ForEach-Object { Write-Info $_ }

    if ($LASTEXITCODE -eq 0) {
        Write-Success "$($template.ShortName) uninstalled."
        $passed++
        $results += [PSCustomObject]@{ Template = $template.ShortName; Status = 'Uninstalled' }
    }
    else {
        # Exit code 1 often means the template was not installed — treat as a warning
        Write-Warn "'$($template.ShortName)' was not installed or could not be uninstalled."
        $results += [PSCustomObject]@{ Template = $template.ShortName; Status = 'Not found' }
    }
}

# ---------------------------------------------------------------------------

Write-Banner 'Summary'
$results | Format-Table -AutoSize

Write-Host "  Uninstalled : $passed" -ForegroundColor Green
Write-Host ''

