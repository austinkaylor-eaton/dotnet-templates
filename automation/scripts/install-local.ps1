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

Write-Banner 'Install Eaton.AustinKaylor.Templates Locally'

Write-Step "Packing Template Package"
$repoRoot   = Get-RepoRoot
$templatePackProject = Join-Path $repoRoot "templates\Eaton.AustinKaylor.Templates.csproj"
dotnet pack $templatePackProject -c Release
Assert-Success $LASTEXITCODE 'dotnet pack'

Write-Step "Installing Local Template NuGet Package"
$templatePackageId = 'Eaton.AustinKaylor.Templates'
$templateVersion = Get-PackageVersion
$localTemplateNugetPackage = Join-Path $repoRoot "templates\bin\Release\$templatePackageId.$templateVersion.nupkg"

if ($Force) {
    Write-Info "-Force specified. Reinstalling template package."
    $uninstallOutput = dotnet new uninstall $templatePackageId 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Info "Removed existing local template installation."
    }
    else {
        Write-Warn "No existing '$templatePackageId' installation was removed. Continuing with install."
        if ($uninstallOutput) {
            Write-Info (($uninstallOutput | Out-String).Trim())
        }
    }
}

$installOutput = dotnet new install $localTemplateNugetPackage 2>&1
$installExitCode = $LASTEXITCODE
if ($installExitCode -ne 0) {
    $installOutputText = ($installOutput | Out-String)
    if ($installOutputText -match 'already installed|currently installed|already exists') {
        Write-Warn "Template package is already installed."
        Write-Info "Use -Force to uninstall and reinstall the local package."
    }
    else {
        Write-Failure $installOutputText.Trim()
        throw "dotnet new install failed with exit code $installExitCode."
    }
}

Write-Step "Finishing Notes"
Write-Info "Run 'dotnet new list' to see installed templates."
Write-Info "Use 'local_testing/' to generate and test template output."

