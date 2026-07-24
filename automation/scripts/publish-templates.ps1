# publish-templates.ps1
# Pushes the template NuGet package to a feed.
#
# By default, targets nuget.org. Override -NuGetSource for an internal feed.
# If -Version is not specified, the script picks the most recently created .nupkg
# in artifacts/nuget_packages/.
#
# Usage:
#   .\publish-templates.ps1 -ApiKey YOUR_KEY
#   .\publish-templates.ps1 -Version 1.2.0 -ApiKey YOUR_KEY
#   .\publish-templates.ps1 -Version 1.2.0 -NuGetSource https://pkgs.dev.azure.com/yourorg/_packaging/yourfeed/nuget/v3/index.json -ApiKey YOUR_KEY

param(
    # The package version to publish. Defaults to the most recent .nupkg in artifacts/nuget_packages/.
    [string]$Version = '',

    # The NuGet feed URL to push to.
    [string]$NuGetSource = 'https://api.nuget.org/v3/index.json',

    # The NuGet API key for the target feed.
    # For nuget.org, generate at https://www.nuget.org/account/apikeys
    # For Azure Artifacts, use 'az artifacts credentials show' or a PAT.
    [string]$ApiKey = '',

    # When set, shows the push command without executing it.
    [switch]$WhatIf
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'shared.ps1')

# ---------------------------------------------------------------------------
# Resolve the package to publish
# ---------------------------------------------------------------------------

$packagesPath = Get-NugetPackagesPath

if (-not (Test-Path $packagesPath)) {
    Write-Failure "Packages directory not found: $packagesPath"
    Write-Info "Run .\pack-templates.ps1 first."
    exit 1
}

if ($Version) {
    $packageFile = Get-ChildItem -Path $packagesPath -Filter "Eaton.AustinKaylor.Templates.$Version.nupkg" |
        Select-Object -First 1
    if (-not $packageFile) {
        Write-Failure "Package Eaton.AustinKaylor.Templates.$Version.nupkg not found in $packagesPath"
        exit 1
    }
}
else {
    # Pick the most recently created package
    $packageFile = Get-ChildItem -Path $packagesPath -Filter 'Eaton.AustinKaylor.Templates.*.nupkg' |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $packageFile) {
        Write-Failure "No .nupkg files found in $packagesPath"
        Write-Info "Run .\pack-templates.ps1 first."
        exit 1
    }

    Write-Warn "No -Version specified. Using most recent package: $($packageFile.Name)"
}

# ---------------------------------------------------------------------------
# Pre-flight checks
# ---------------------------------------------------------------------------

Write-Banner "Publish Templates"
Write-Info "Package : $($packageFile.FullName)"
Write-Info "Feed    : $NuGetSource"
Write-Info "WhatIf  : $($WhatIf.IsPresent)"

if (-not $ApiKey -and -not $WhatIf) {
    Write-Failure "An API key is required. Pass -ApiKey or set NUGET_API_KEY in the environment."
    Write-Info "Example: .\publish-templates.ps1 -Version 1.0.0 -ApiKey `$env:NUGET_API_KEY"
    exit 1
}

# Allow the key to come from an environment variable as a fallback
if (-not $ApiKey) {
    $ApiKey = $env:NUGET_API_KEY
}

# ---------------------------------------------------------------------------
# Push
# ---------------------------------------------------------------------------

Write-Step 'Pushing package...'

$pushArgs = @(
    'nuget', 'push',
    $packageFile.FullName,
    '--source', $NuGetSource,
    '--api-key', $ApiKey,
    '--skip-duplicate'
)

if ($WhatIf) {
    Write-Warn "[WhatIf] Would run: dotnet $($pushArgs -join ' ')"
    Write-Info 'No package was published.'
    exit 0
}

& dotnet @pushArgs 2>&1 | ForEach-Object { Write-Info $_ }

Assert-Success $LASTEXITCODE 'dotnet nuget push'

# ---------------------------------------------------------------------------
# Confirm
# ---------------------------------------------------------------------------

Write-Banner 'Publish Complete'
Write-Success "$($packageFile.Name) published to $NuGetSource"
Write-Host ''
Write-Info "Users can now install the templates with:"
Write-Info "  dotnet new install Eaton.AustinKaylor.Templates"

