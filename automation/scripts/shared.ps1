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
    Write-Debug "PSScriptRoot: $PSScriptRoot"
    $repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    Write-Debug "Repository Root: $repositoryRoot"
    return $repositoryRoot
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
    Returns a single line of consecutive dashes.
    Defaults to 60 dashes.
#>
function Get-Divider-Line([int]$NumberOfDashes = 60) {
    return '-' * $NumberOfDashes
}

<#
.SYNOPSIS
    Writes a section banner to the console.
#>
function Write-Banner([string]$Message) {
    $line = Get-Divider-Line(60)
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
    Write-Host "[STEP] $Message" -ForegroundColor Cyan
}

<#
.SYNOPSIS
    Writes an informational message.
#>
function Write-Info([string]$Message) {
    Write-Host "[INFO] $Message" -ForegroundColor Gray
}

<#
.SYNOPSIS
    Writes a success message.
#>
function Write-Success([string]$Message) {
    Write-Host "[OK] $Message" -ForegroundColor Green
}

<#
.SYNOPSIS
    Writes a warning message without stopping execution.
#>
function Write-Warn([string]$Message) {
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

<#
.SYNOPSIS
    Writes an error message without stopping execution.
#>
function Write-Failure([string]$Message) {
    Write-Host "[FAIL] $Message" -ForegroundColor Red
}

<#
.SYNOPSIS
    Writes a debug message.
#>
#function Write-Debug([string]$Message) {
#    Write-Host "    [DEBUG] $Message" -ForegroundColor DarkGray
#}

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
    $knownTypes = @('item', 'project', 'solution')
    $seenRoots = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

    $templateJsonFiles = Get-ChildItem -Path $templatesRoot -Recurse -File -Filter 'template.json' -ErrorAction SilentlyContinue

    foreach ($templateJson in $templateJsonFiles) {
        $configDir = Split-Path -Parent $templateJson.FullName
        if ((Split-Path -Leaf $configDir) -ne '.template.config') {
            continue
        }

        $templateRoot = Split-Path -Parent $configDir
        if (-not $templateRoot) {
            continue
        }

        $relativeRoot = $templateRoot.Substring($templatesRoot.Length).TrimStart('\', '/')
        if ([string]::IsNullOrWhiteSpace($relativeRoot)) {
            continue
        }

        $segments = $relativeRoot -split '[\\/]'
        $type = $segments[0].ToLowerInvariant()
        if ($type -notin $knownTypes) {
            continue
        }

        if ($segments -contains 'bin' -or $segments -contains 'obj') {
            continue
        }

        try {
            $normalizedRoot = (Resolve-Path $templateRoot).Path
            $config = Get-Content $templateJson.FullName -Raw | ConvertFrom-Json
        }
        catch {
            Write-Warn "Skipping '$templateRoot': template.json could not be parsed."
            continue
        }

        if (-not $seenRoots.Add($normalizedRoot)) {
            continue
        }

        $results += [PSCustomObject]@{
            SrcPath   = $normalizedRoot
            Type      = $type
            Name      = $config.name
            Identity  = $config.identity
            ShortName = $config.shortName
        }
    }

    return $results | Sort-Object Type, ShortName
}

# ---------------------------------------------------------------------------
# Version management
# ---------------------------------------------------------------------------

<#
.SYNOPSIS
    Reads the package version from templates/Eaton.AustinKaylor.Templates.csproj.
    Returns '0.1.0' when the file does not exist.

.EXAMPLE
    $version = Get-PackageVersion
#>
function Get-PackageVersion {
    Write-Debug "Get-PackageVersion"
    $line = Get-Divider-Line(60)
    Write-Debug $line
    $versionFile = Join-Path (Get-RepoRoot) 'templates\Eaton.AustinKaylor.Templates.csproj'
    Write-Debug $versionFile
    if (-not (Test-Path $versionFile)) {
        Write-Debug "Template package project not found. Using default version 0.1.0"
        return '0.1.0'
    }

    [xml]$projectXml = Get-Content -Path $versionFile -Raw
    Write-Debug $projectXml

    # Handle multiple PropertyGroup nodes; return first non-empty PackageVersion
    foreach ($group in @($projectXml.Project.PropertyGroup)) {
        if ($group.PackageVersion -and -not [string]::IsNullOrWhiteSpace([string]$group.PackageVersion)) {
            Write-Debug "Found PackageVersion: $($group.PackageVersion)"
            return [string]$group.PackageVersion
        }
        # Fallback incase PackageVersion is not used and Version is present instead
        if ($group.Version -and -not [string]::IsNullOrWhiteSpace([string]$group.Version)) {
            Write-Debug "Found Version: $($group.Version)"
            return [string]$group.Version
        }
    }

    Write-Debug "Template package project not found. Using default version 0.1.0"
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

