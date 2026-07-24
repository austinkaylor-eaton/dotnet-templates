# install-local.ps1
# Installs all templates in this repository to the local dotnet template cache.
# Run this script when you want to test templates with 'dotnet new' without publishing a package.
#
# Usage:
#   .\install-local.ps1
#   .\install-local.ps1 -Force

param(
    # Re-install templates even if they are already installed.
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'shared.ps1')

# ---------------------------------------------------------------------------

Write-Banner 'Install Templates Locally'

$templates = Get-AllTemplates

if ($templates.Count -eq 0) {
    Write-Warn 'No templates found. Add templates under templates/item/ or templates/project/ and try again.'
    exit 0
}

$passed  = 0
$failed  = 0
$results = @()

foreach ($template in $templates) {
    Write-Step "Installing '$($template.Identity)'"
    Write-Info "Source: $($template.SrcPath)"

    $installArgs = @('new', 'install', $template.SrcPath)
    if ($Force) { $installArgs += '--force' }

    & dotnet @installArgs 2>&1 | ForEach-Object { Write-Info $_ }

    if ($LASTEXITCODE -eq 0) {
        Write-Success "$($template.ShortName) installed."
        $passed++
        $results += [PSCustomObject]@{ Template = $template.ShortName; Status = 'Installed' }
    }
    else {
        Write-Failure "Failed to install '$($template.ShortName)'."
        $failed++
        $results += [PSCustomObject]@{ Template = $template.ShortName; Status = 'Failed' }
    }
}

# ---------------------------------------------------------------------------

Write-Banner 'Summary'
$results | Format-Table -AutoSize

Write-Host "  Installed : $passed" -ForegroundColor Green
if ($failed -gt 0) {
    Write-Host "  Failed    : $failed" -ForegroundColor Red
    exit 1
}

Write-Host ''
Write-Info "Run 'dotnet new list' to see installed templates."
Write-Info "Use 'local_testing/' to generate and test template output."

