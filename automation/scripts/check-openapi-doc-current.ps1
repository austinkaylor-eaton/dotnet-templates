<#
.SYNOPSIS
    Builds TodoApi and verifies that TodoApi.json is up to date.

.DESCRIPTION
    This script builds the TodoApi project, confirms that TodoApi.json exists,
    and checks for OpenAPI drift with `git diff --exit-code`.

    If drift is detected, the script exits non-zero and prints actionable
    commands to regenerate and commit the updated spec.

.NOTES
    Run this script from any location. Paths are resolved relative to this script.

.EXAMPLE
    pwsh -File Scripts/EnsureOpenApiSpecUpToDate.ps1
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Logging helpers
# ---------------------------------------------------------------------------
function Write-Step {
    param([string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Write-Ok {
    param([string]$Message)
    Write-Host "  [OK]   $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "  [INFO] $Message"
}

function Write-Fail {
    param([string]$Message)
    Write-Host "  [FAIL] $Message" -ForegroundColor Red
    exit 1
}

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
$scriptDir = $PSScriptRoot
$projectDir = (Resolve-Path (Join-Path $scriptDir '..')).Path
$csprojPath = Join-Path $projectDir 'TodoApi.csproj'
$openApiPath = Join-Path $projectDir 'TodoApi.json'

# ---------------------------------------------------------------------------
# Build and generate OpenAPI
# ---------------------------------------------------------------------------
Write-Step 'Building TodoApi project to generate OpenAPI output'

if (-not (Test-Path $csprojPath)) {
    Write-Fail "Project file not found: $csprojPath"
}

Write-Info 'Running dotnet build...'
dotnet build $csprojPath --nologo -v minimal
if ($LASTEXITCODE -ne 0) {
    Write-Fail "dotnet build failed with exit code $LASTEXITCODE."
}

if (-not (Test-Path $openApiPath)) {
    Write-Fail "Expected OpenAPI file was not generated: $openApiPath"
}

Write-Ok "Generated OpenAPI file found: $openApiPath"

# ---------------------------------------------------------------------------
# Drift check
# ---------------------------------------------------------------------------
Write-Step 'Checking for uncommitted OpenAPI spec changes'
Write-Info 'Running git diff --exit-code...'

git --no-pager diff --exit-code -- $openApiPath
if ($LASTEXITCODE -ne 0) {
    Write-Host ''
    Write-Host "ERROR: $openApiPath is out of date." -ForegroundColor Yellow
    Write-Host 'Run these commands and commit the result:' -ForegroundColor Yellow
    Write-Host "  dotnet build `"$csprojPath`" --nologo -v minimal" -ForegroundColor Yellow
    Write-Host "  git add `"$openApiPath`"" -ForegroundColor Yellow
    Write-Host "  git commit -m `"Update generated OpenAPI spec`"" -ForegroundColor Yellow
    Write-Fail 'OpenAPI spec drift detected.'
}

Write-Ok 'OpenAPI spec is up to date.'