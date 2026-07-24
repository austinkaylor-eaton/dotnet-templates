# shared.ps1
# Shared helpers used by all automation scripts in this repository.
# Dot-source this file at the top of every script:
#   . (Join-Path $PSScriptRoot 'shared.ps1')

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Path helpers
# ---------------------------------------------------------------------------

<#
.SYNOPSIS
    Returns the absolute path to the repository root.
#>
function Get-RepoRoot {
    return (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

<#
.SYNOPSIS
    Returns the absolute path to the templates directory.
#>
function Get-TemplatesRoot {
    return Join-Path (Get-RepoRoot) 'templates'
}

<#
.SYNOPSIS
    Returns the absolute path to the artifacts directory.
#>
function Get-ArtifactsRoot {
    return Join-Path (Get-RepoRoot) 'artifacts'
}

<#
.SYNOPSIS
    Returns the absolute path to the NuGet packages output directory.
#>
function Get-NugetPackagesPath {
    return Join-Path (Get-ArtifactsRoot) 'nuget_packages'
}

<#
.SYNOPSIS
    Returns the absolute path to the logs output directory.
#>
function Get-LogsPath {
    return Join-Path (Get-ArtifactsRoot) 'logs'
}

<#
.SYNOPSIS
    Returns the absolute path to the local testing sandbox.
#>
function Get-LocalTestingPath {
    return Join-Path (Get-RepoRoot) 'local_testing'
}

# ---------------------------------------------------------------------------
# Logging helpers
# ---------------------------------------------------------------------------

<#
.SYNOPSIS
    Writes a section banner to the console.
#>
function Write-Banner([string]$Message) {
    $line = '-' * 60
    Write-Host ''
    Write-Host $line -ForegroundColor DarkGray
    Write-Host "  $Message" -ForegroundColor White
    Write-Host $line -ForegroundColor DarkGray
}

<#
.SYNOPSIS
    Writes a top-level step heading.
#>
function Write-Step([string]$Message) {
    Write-Host "`n  $Message" -ForegroundColor Cyan
}

<#
.SYNOPSIS
    Writes an informational message.
#>
function Write-Info([string]$Message) {
    Write-Host "    $Message" -ForegroundColor Gray
}

<#
.SYNOPSIS
    Writes a success message.
#>
function Write-Success([string]$Message) {
    Write-Host "    [OK] $Message" -ForegroundColor Green
}

<#
.SYNOPSIS
    Writes a warning message without stopping execution.
#>
function Write-Warn([string]$Message) {
    Write-Host "    [WARN] $Message" -ForegroundColor Yellow
}

<#
.SYNOPSIS
    Writes an error message without stopping execution.
#>
function Write-Failure([string]$Message) {
    Write-Host "    [FAIL] $Message" -ForegroundColor Red
}

# ---------------------------------------------------------------------------
# Template discovery
# ---------------------------------------------------------------------------

<#
.SYNOPSIS
    Returns a list of objects describing every template found in the repository.

.DESCRIPTION
    Searches templates/item, templates/project, and templates/solution for
    subdirectories that contain a src/.template.config/template.json file.
    Returns objects with these properties:
        SrcPath   - Full path to the template's src/ folder
        Type      - Template type: item, project, or solution
        Name      - Human-readable name from template.json
        Identity  - Full identity string from template.json
        ShortName - Short name(s) from template.json

.EXAMPLE
    $templates = Get-AllTemplates
    foreach ($t in $templates) { Write-Info $t.Identity }
#>
function Get-AllTemplates {
    $templatesRoot = Get-TemplatesRoot
    $results = @()

    foreach ($type in @('item', 'project', 'solution')) {
        $typePath = Join-Path $templatesRoot $type
        if (-not (Test-Path $typePath)) { continue }

        foreach ($templateDir in Get-ChildItem -Path $typePath -Directory) {
            $srcPath   = Join-Path $templateDir.FullName 'src'
            $configPath = Join-Path $srcPath '.template.config\template.json'

            if (-not (Test-Path $configPath)) {
                Write-Warn "Skipping '$($templateDir.Name)': no src/.template.config/template.json found."
                continue
            }

            try {
                $config = Get-Content $configPath -Raw | ConvertFrom-Json
            }
            catch {
                Write-Warn "Skipping '$($templateDir.Name)': template.json could not be parsed."
                continue
            }

            $results += [PSCustomObject]@{
                SrcPath   = $srcPath
                Type      = $type
                Name      = $config.name
                Identity  = $config.identity
                ShortName = $config.shortName
            }
        }
    }

    return $results
}

# ---------------------------------------------------------------------------
# Version management
# ---------------------------------------------------------------------------

<#
.SYNOPSIS
    Reads the package version from automation/version.json.
    Returns '0.1.0' when the file does not exist.

.EXAMPLE
    $version = Get-PackageVersion
#>
function Get-PackageVersion {
    $versionFile = Join-Path (Get-RepoRoot) 'automation\version.json'
    if (Test-Path $versionFile) {
        $data = Get-Content $versionFile -Raw | ConvertFrom-Json
        if ($data.version) { return $data.version }
    }
    return '0.1.0'
}

# ---------------------------------------------------------------------------
# Output directories
# ---------------------------------------------------------------------------

<#
.SYNOPSIS
    Ensures the artifacts output directories exist.
#>
function Initialize-OutputDirectories {
    foreach ($dir in @((Get-NugetPackagesPath), (Get-LogsPath))) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }
}

# ---------------------------------------------------------------------------
# Assertion helpers
# ---------------------------------------------------------------------------

<#
.SYNOPSIS
    Throws a terminating error with a descriptive message.
#>
function Assert-Success([int]$ExitCode, [string]$Context) {
    if ($ExitCode -ne 0) {
        throw "$Context failed with exit code $ExitCode."
    }
}

