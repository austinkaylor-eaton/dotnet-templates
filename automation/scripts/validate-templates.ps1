# validate-templates.ps1
# Validates all templates in the repository.
#
# Validation steps for each template:
#   1. Check that template.json is valid JSON
#   2. Check that template.json contains required fields
#   3. Warn if stale bin/ or obj/ directories exist in the template source
#   4. Optionally generate the template and build it (project templates only)
#
# Usage:
#   .\validate-templates.ps1
#   .\validate-templates.ps1 -SkipBuild
#
# Output:
#   Pass/fail per template, plus a log written to artifacts/logs/

param(
    # Skip the generate-and-build step. Useful for fast JSON-only validation.
    [switch]$SkipBuild
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'shared.ps1')

Initialize-OutputDirectories

$logFile  = Join-Path (Get-LogsPath) "validate-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
$repoRoot = Get-RepoRoot

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

function Write-Log([string]$Message) {
    $timestamped = "[$(Get-Date -Format 'HH:mm:ss')] $Message"
    Add-Content -Path $logFile -Value $timestamped
}

function Test-TemplateJson([string]$SrcPath) {
    <#
    .SYNOPSIS
        Validates template.json structure and required fields.
    #>

    $configPath = Join-Path $SrcPath '.template.config\template.json'

    # Parse JSON
    try {
        $config = Get-Content $configPath -Raw | ConvertFrom-Json
    }
    catch {
        return "template.json is not valid JSON: $_"
    }

    # Required top-level fields
    $required = @('identity', 'shortName', 'name', 'author', 'description')
    foreach ($field in $required) {
        if (-not $config.$field) {
            return "template.json is missing required field '$field'."
        }
    }

    # Required tags
    if (-not $config.tags -or -not $config.tags.language -or -not $config.tags.type) {
        return "template.json is missing 'tags.language' or 'tags.type'."
    }

    return $null  # No error
}

function Test-NoStaleArtifacts([string]$SrcPath) {
    <#
    .SYNOPSIS
        Returns a warning message if stale build artifacts exist inside the template source.
    #>

    $stalePatterns = @('bin', 'obj', '.vs', '.user')
    $found = @()

    foreach ($pattern in $stalePatterns) {
        $matches = Get-ChildItem -Path $SrcPath -Recurse -Filter $pattern -ErrorAction SilentlyContinue
        foreach ($match in $matches) {
            $found += $match.FullName.Replace($SrcPath, '').TrimStart('\/')
        }
    }

    return $found
}

function Invoke-GenerateAndBuild([PSCustomObject]$Template, [string]$OutputDir) {
    <#
    .SYNOPSIS
        Generates a template into a temp directory and builds it if it is a project template.
    #>

    # Generate
    Write-Log "Generating '$($Template.ShortName)' into $OutputDir"
    & dotnet new $Template.ShortName --output $OutputDir --force 2>&1 | ForEach-Object {
        Write-Log "  [generate] $_"
    }

    if ($LASTEXITCODE -ne 0) {
        return "Generation failed with exit code $LASTEXITCODE."
    }

    # Build only project and solution templates
    if ($Template.Type -notin @('project', 'solution')) {
        return $null
    }

    # Find a .csproj or .sln to build
    $projectFile = Get-ChildItem -Path $OutputDir -Recurse -Include '*.csproj', '*.sln' |
        Select-Object -First 1

    if (-not $projectFile) {
        return $null  # No project to build is acceptable (e.g., solution that needs args)
    }

    Write-Log "Building '$($projectFile.Name)'"
    & dotnet build $projectFile.FullName --nologo --verbosity quiet 2>&1 | ForEach-Object {
        Write-Log "  [build] $_"
    }

    if ($LASTEXITCODE -ne 0) {
        return "Build failed with exit code $LASTEXITCODE."
    }

    return $null  # Success
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

Write-Banner 'Validate Templates'
Write-Log 'Validation started'

$templates = Get-AllTemplates

if ($templates.Count -eq 0) {
    Write-Warn 'No templates found. Add templates under templates/item/ or templates/project/ and try again.'
    exit 0
}

$passed  = 0
$warned  = 0
$failed  = 0
$results = @()

# Install templates before running generate tests
if (-not $SkipBuild) {
    Write-Step 'Installing templates for generation tests...'
    & dotnet new install $repoRoot\templates --force 2>&1 | Out-Null
}

foreach ($template in $templates) {
    Write-Step "Validating '$($template.Identity)'"
    Write-Log "--- Validating $($template.Identity) ---"

    $errors   = @()
    $warnings = @()

    # 1. Validate template.json
    $jsonError = Test-TemplateJson -SrcPath $template.SrcPath
    if ($jsonError) { $errors += $jsonError }

    # 2. Check for stale build artifacts
    $staleFiles = Test-NoStaleArtifacts -SrcPath $template.SrcPath
    foreach ($stale in $staleFiles) {
        $warnings += "Stale artifact found: $stale"
    }

    # 3. Generate + build
    if (-not $SkipBuild -and $errors.Count -eq 0) {
        $tempOut = Join-Path (Get-LocalTestingPath) "validate-$($template.ShortName)-$(Get-Date -Format 'HHmmss')"

        try {
            $buildError = Invoke-GenerateAndBuild -Template $template -OutputDir $tempOut
            if ($buildError) { $errors += $buildError }
        }
        finally {
            if (Test-Path $tempOut) {
                Remove-Item -Recurse -Force $tempOut -ErrorAction SilentlyContinue
            }
        }
    }

    # Aggregate results
    foreach ($w in $warnings) { Write-Warn $w; Write-Log "[WARN] $w" }
    foreach ($e in $errors)   { Write-Failure $e; Write-Log "[FAIL] $e" }

    if ($errors.Count -gt 0) {
        $status = 'Failed'
        $failed++
    }
    elseif ($warnings.Count -gt 0) {
        $status = 'Passed (with warnings)'
        $warned++
        $passed++
        Write-Success "Passed (with $($warnings.Count) warning(s))."
    }
    else {
        $status = 'Passed'
        $passed++
        Write-Success 'Passed.'
    }

    $results += [PSCustomObject]@{
        Template = $template.ShortName
        Type     = $template.Type
        Status   = $status
    }

    Write-Log "Result: $status"
}

# Uninstall after tests
if (-not $SkipBuild) {
    & dotnet new uninstall $repoRoot\templates 2>&1 | Out-Null
}

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

Write-Banner 'Validation Summary'
$results | Format-Table -AutoSize

Write-Host "  Passed  : $passed" -ForegroundColor Green
if ($warned -gt 0)  { Write-Host "  Warned  : $warned"  -ForegroundColor Yellow }
if ($failed -gt 0)  { Write-Host "  Failed  : $failed"  -ForegroundColor Red }

Write-Host ''
Write-Info "Log written to: $logFile"
Write-Log "Validation complete. Passed=$passed, Warned=$warned, Failed=$failed"

if ($failed -gt 0) { exit 1 }

