<#
.SYNOPSIS
    Installs the latest Spectral CLI and runs lint against the TodoApi OpenAPI document.

.DESCRIPTION
    Detects the operating system and installs Spectral accordingly:
      - Linux   : uses the official install.sh from Spectral's GitHub repository.
      - Windows : downloads the latest release binary from GitHub to a repo-local
                  Tools/ folder (TodoApi/Tools/spectral.exe).

    After installation the script:
      1. Verifies the CLI with `spectral --version`.
      2. Generates the OpenAPI document via `dotnet build` when it does not yet exist.
      3. Runs `spectral lint` against TodoApi/.spectral.yml.

.NOTES
    Requires PowerShell 7+ (pwsh). On Windows, Spectral is installed to
    <ProjectDir>/Tools/spectral.exe and added to $env:PATH for the current session only.
    No machine-wide changes are made.

.EXAMPLE
    pwsh -File Scripts/RunSpectralLint.ps1
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Require PowerShell 7+ ($IsLinux / $IsWindows are not available in PS 5)
# ---------------------------------------------------------------------------
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Error "This script requires PowerShell 7 or later (pwsh). Current version: $($PSVersionTable.PSVersion)"
    exit 1
}

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
$ScriptDir      = $PSScriptRoot                                         # .../TodoApi/Scripts/
$ProjectDir     = (Resolve-Path (Join-Path $ScriptDir '..')).Path       # .../TodoApi/
$ToolsDir       = Join-Path $ProjectDir 'Tools'                         # .../TodoApi/Tools/
$SpectralExe    = Join-Path $ToolsDir 'spectral.exe'                    # Windows binary target
$SpectralConfig = Join-Path $ProjectDir '.spectral.yml'                 # Spectral ruleset
$OpenApiDoc     = Join-Path $ProjectDir 'v1.json'                       # Runtime endpoint name fallback
$CsprojPath     = Join-Path $ProjectDir 'TodoApi.csproj'
$ProjectName    = [System.IO.Path]::GetFileNameWithoutExtension($CsprojPath)

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
# OS detection
# ---------------------------------------------------------------------------
function Get-OperatingSystem {
    # $IsLinux / $IsWindows are PowerShell 7+ automatic variables
    if ($IsLinux)   { return 'Linux' }
    if ($IsWindows) { return 'Windows' }
    Write-Fail 'Unsupported operating system. This script supports Linux and Windows only.'
}

# ---------------------------------------------------------------------------
# Linux: official install script
# ---------------------------------------------------------------------------
function Install-SpectralLinux {
    Write-Step 'Installing Spectral CLI on Linux via official install script'

    if (-not (Get-Command curl -ErrorAction SilentlyContinue)) {
        Write-Fail 'curl is required but was not found. Install curl and re-run this script.'
    }

    bash -c 'curl -L https://raw.github.com/stoplightio/spectral/master/scripts/install.sh | sh'

    if ($LASTEXITCODE -ne 0) {
        Write-Fail "Spectral installation script exited with code $LASTEXITCODE."
    }

    Write-Ok 'Spectral installed.'
}

# ---------------------------------------------------------------------------
# Windows: download latest release binary from GitHub to repo-local Tools/
# ---------------------------------------------------------------------------
function Install-SpectralWindows {
    Write-Step 'Installing Spectral CLI on Windows from GitHub Releases'

    # Create Tools/ directory if it does not exist
    if (-not (Test-Path $ToolsDir)) {
        New-Item -ItemType Directory -Path $ToolsDir | Out-Null
        Write-Ok "Created Tools directory: $ToolsDir"
    }

    # Fetch latest release metadata from GitHub API
    Write-Info 'Fetching latest release info from GitHub API...'
    $apiUrl  = 'https://api.github.com/repos/stoplightio/spectral/releases/latest'
    $headers = @{
        'User-Agent' = 'spectral-installer-ps1'
        'Accept'     = 'application/vnd.github+json'
    }

    try {
        $release = Invoke-RestMethod -Uri $apiUrl -Headers $headers
    }
    catch {
        Write-Fail "GitHub API request failed: $_"
    }

    $version = $release.tag_name
    Write-Info "Latest release: $version"

    # Locate the Windows executable asset (released as spectral.exe)
    $asset = $release.assets |
        Where-Object { $_.name -match '\.exe$' } |
        Select-Object -First 1

    if (-not $asset) {
        $available = ($release.assets | ForEach-Object { $_.name }) -join ', '
        Write-Fail "No Windows .exe asset found in release $version. Available assets: $available"
    }

    Write-Info "Downloading $($asset.name)..."
    try {
        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $SpectralExe -UseBasicParsing
    }
    catch {
        Write-Fail "Download failed: $_"
    }

    # Add Tools/ to PATH for this session so downstream commands can resolve 'spectral'
    if ($env:PATH -notlike "*$ToolsDir*") {
        $env:PATH = "$ToolsDir$([System.IO.Path]::PathSeparator)$env:PATH"
        Write-Ok "Added $ToolsDir to PATH for this session."
    }

    Write-Ok "Spectral $version installed to: $SpectralExe"
}

# ---------------------------------------------------------------------------
# Verify Spectral is accessible and print the resolved version
# ---------------------------------------------------------------------------
function Assert-SpectralInstalled {
    Write-Step 'Verifying Spectral CLI'

    # On Windows prefer the known repo-local binary to avoid PATH ambiguity
    if ($IsWindows -and (Test-Path $SpectralExe)) {
        $spectralCmd = $SpectralExe
    }
    else {
        $resolved = Get-Command spectral -ErrorAction SilentlyContinue
        $spectralCmd = if ($resolved) { $resolved.Source } else { $null }
    }

    if (-not $spectralCmd) {
        Write-Fail 'spectral command not found after installation. Check the output above.'
    }

    $versionOutput = & $spectralCmd --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Fail "spectral --version exited with code $LASTEXITCODE. Output: $versionOutput"
    }

    Write-Ok "spectral $versionOutput"

    # Return the resolved command path so subsequent steps use the same binary
    return $spectralCmd
}

# ---------------------------------------------------------------------------
# Ensure the OpenAPI document exists; generate it via dotnet build if absent
# ---------------------------------------------------------------------------
function Resolve-OpenApiDocument {
    Write-Step 'Resolving OpenAPI document'

    # Known naming patterns: runtime endpoint (v1.json) and build-time generator default (<ProjectName>.json)
    $preferredCandidates = @(
        $OpenApiDoc,
        (Join-Path $ProjectDir "$ProjectName.json")
    )

    foreach ($candidate in $preferredCandidates) {
        if (Test-Path $candidate) {
            $script:OpenApiDoc = $candidate
            Write-Ok "Found: $script:OpenApiDoc"
            return
        }
    }

    Write-Info 'OpenAPI document not found — running dotnet build to generate it...'

    if (-not (Test-Path $CsprojPath)) {
        Write-Fail "TodoApi.csproj not found at: $CsprojPath"
    }

    dotnet build $CsprojPath --nologo -v q
    if ($LASTEXITCODE -ne 0) {
        Write-Fail "dotnet build failed (exit code $LASTEXITCODE). Fix build errors and re-run."
    }

    foreach ($candidate in $preferredCandidates) {
        if (Test-Path $candidate) {
            $script:OpenApiDoc = $candidate
            Write-Ok "Generated: $script:OpenApiDoc"
            return
        }
    }

    # Final fallback: locate a root-level JSON file that looks like an OpenAPI document.
    $jsonFiles = Get-ChildItem -Path $ProjectDir -Filter '*.json' -File
    foreach ($jsonFile in $jsonFiles) {
        try {
            $jsonContent = Get-Content -Path $jsonFile.FullName -Raw | ConvertFrom-Json
            if ($jsonContent.openapi) {
                $script:OpenApiDoc = $jsonFile.FullName
                Write-Ok "Generated: $script:OpenApiDoc"
                return
            }
        }
        catch {
            # Ignore non-JSON or unexpected structures and keep scanning.
        }
    }

    Write-Fail (
        "Build succeeded but no OpenAPI JSON document was found in $ProjectDir. " +
        'Verify OpenApiGenerateDocuments/OpenApiDocumentsDirectory in TodoApi.csproj and ensure AddOpenApi() is configured.'
    )
}

# ---------------------------------------------------------------------------
# Run spectral lint against the TodoApi OpenAPI document
# ---------------------------------------------------------------------------
function Invoke-SpectralLint {
    param([string]$SpectralCommand)

    Write-Step 'Running Spectral lint'

    if (-not (Test-Path $SpectralConfig)) {
        Write-Fail "Spectral ruleset not found at: $SpectralConfig"
    }

    Write-Info "Ruleset : $SpectralConfig"
    Write-Info "Document: $OpenApiDoc"
    Write-Host ''

    & $SpectralCommand lint $OpenApiDoc --ruleset $SpectralConfig

    if ($LASTEXITCODE -ne 0) {
        Write-Host ''
        Write-Fail "Spectral lint reported violations (exit code $LASTEXITCODE). Review the output above."
    }

    Write-Ok 'Lint completed. Spectral exits non-zero for configured fail severities only; review warnings above if present.'
}

# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------
$os = Get-OperatingSystem
Write-Host "Detected OS: $os" -ForegroundColor Yellow

switch ($os) {
    'Linux'   { Install-SpectralLinux }
    'Windows' { Install-SpectralWindows }
}

$spectralCommand = Assert-SpectralInstalled
Resolve-OpenApiDocument
Invoke-SpectralLint -SpectralCommand $spectralCommand

Write-Host "`nDone." -ForegroundColor Green
