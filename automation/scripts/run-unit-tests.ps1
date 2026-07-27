# run-unit-tests.ps1
# Runs template unit tests under tests/ with optional template type selection
# and pass-through test runner arguments for Microsoft.Testing.Platform/TUnit.
#
# Usage examples:
#   .\run-unit-tests.ps1
#   .\run-unit-tests.ps1 -TemplateType item
#   .\run-unit-tests.ps1 -TemplateType item,project -FailOnMissingProject
#   .\run-unit-tests.ps1 -TemplateType item -Filter "FullyQualifiedName~Builder"
#   .\run-unit-tests.ps1 -TemplateType item -RunnerArguments '--output','Detailed'

[CmdletBinding()]
param(
    # Template test groups to run. Use 'all' to include item, project, and solution.
    [ValidateSet('all', 'item', 'project', 'solution')]
    [string[]]$TemplateType = @('all'),

    # Fail when a selected template type has no corresponding test project.
    [switch]$FailOnMissingProject,

    # Optional test filter expression passed to Microsoft.Testing.Platform/TUnit (--filter).
    [string]$Filter,

    # Additional arguments passed through to Microsoft.Testing.Platform/TUnit after '--'.
    [Alias('PassThroughArgs', 'MtpArguments')]
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$RunnerArguments
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'shared.ps1')

function Resolve-SelectedTemplateTypes {
    param([string[]]$Requested)

    $allTypes = @('item', 'project', 'solution')
    if ($Requested -contains 'all') {
        return $allTypes
    }

    return $Requested | Select-Object -Unique
}

function Get-TestProjectCandidates {
    param(
        [string]$Type,
        [string]$RepoRoot
    )

    $testsRoot = Join-Path $RepoRoot 'tests'

    $knownPaths = switch ($Type) {
        'item' {
            @(
                Join-Path $testsRoot 'Item.UnitTests\Item.UnitTests.csproj'
                Join-Path $testsRoot 'Item.Tests\Item.Tests.csproj'
            )
        }
        'project' {
            @(
                Join-Path $testsRoot 'Project.UnitTests\Project.UnitTests.csproj'
                Join-Path $testsRoot 'Project.Tests\Project.Tests.csproj'
            )
        }
        'solution' {
            @(
                Join-Path $testsRoot 'Solution.UnitTests\Solution.UnitTests.csproj'
                Join-Path $testsRoot 'Solution.Tests\Solution.Tests.csproj'
            )
        }
        default { @() }
    }

    $resolved = @($knownPaths | Where-Object { Test-Path $_ })

    # Fallback discovery keeps this script forward-compatible with naming changes.
    if ($resolved.Count -eq 0 -and (Test-Path $testsRoot)) {
        $pattern = [System.Text.RegularExpressions.Regex]::Escape($Type)
        $resolved = @(
            Get-ChildItem -Path $testsRoot -Recurse -File -Filter '*.csproj' |
                Where-Object { $_.Name -match "^${pattern}(\.Tests|\.UnitTests)?\.csproj$" } |
                Select-Object -ExpandProperty FullName
        )
    }

    return $resolved | Select-Object -Unique
}

Initialize-OutputDirectories

$repoRoot = Get-RepoRoot
$selectedTypes = Resolve-SelectedTemplateTypes -Requested $TemplateType
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$resultsRoot = Join-Path $repoRoot (Join-Path 'artifacts\test-results' $timestamp)

New-Item -ItemType Directory -Path $resultsRoot -Force | Out-Null

Write-Banner 'Run Unit Tests'
Write-Info "Repository: $repoRoot"
Write-Info "Results   : $resultsRoot"
Write-Info "Templates : $($selectedTypes -join ', ')"
if (-not [string]::IsNullOrWhiteSpace($Filter)) {
    Write-Info "Filter    : $Filter"
}
$runnerArgs = @($RunnerArguments | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
if ($runnerArgs.Count -gt 0 -and $runnerArgs[0] -eq '--') {
    # Allow callers to include a leading '--' for familiarity with dotnet test syntax.
    $runnerArgs = @($runnerArgs | Select-Object -Skip 1)
}

if ($runnerArgs.Count -gt 0) {
    Write-Info "Pass-through args: $($runnerArgs -join ' ')"
}

$failed = 0
$missing = 0
$executed = 0
$results = @()

Push-Location $repoRoot
try {
    foreach ($type in $selectedTypes) {
        $projects = @(Get-TestProjectCandidates -Type $type -RepoRoot $repoRoot)

        if ($projects.Count -eq 0) {
            $missing++
            $message = "No test project found for template type '$type'."
            if ($FailOnMissingProject) {
                Write-Failure $message
                $results += [PSCustomObject]@{ TemplateType = $type; Project = '<missing>'; Status = 'Missing (failed)' }
            }
            else {
                Write-Warn "$message Skipping."
                $results += [PSCustomObject]@{ TemplateType = $type; Project = '<missing>'; Status = 'Missing (skipped)' }
            }

            continue
        }

        foreach ($projectPath in $projects) {
            $executed++
            $projectName = [System.IO.Path]::GetFileNameWithoutExtension($projectPath)
            $projectResultsDir = Join-Path (Join-Path $resultsRoot $type) $projectName

            New-Item -ItemType Directory -Path $projectResultsDir -Force | Out-Null

            Write-Step "[$type] $projectName"

            $mtpArgs = @(
                '--report-trx',
                '--results-directory', $projectResultsDir
            )

            if (-not [string]::IsNullOrWhiteSpace($Filter)) {
                $mtpArgs += @('--filter', $Filter)
            }

            if ($runnerArgs.Count -gt 0) {
                $mtpArgs += $runnerArgs
            }

            $quotedProjectPath = $projectPath.Replace("'", "''")
            $quotedMtpArgs = @($mtpArgs | ForEach-Object { "'" + $_.Replace("'", "''") + "'" })
            $dotnetCommand = "dotnet test --project '$quotedProjectPath' -- $($quotedMtpArgs -join ' ')"

            Write-Info $dotnetCommand
            & pwsh -NoLogo -NoProfile -Command $dotnetCommand
            $exitCode = $LASTEXITCODE

            if ($exitCode -eq 0) {
                Write-Success "Passed: $projectName"
                $status = 'Passed'
            }
            else {
                Write-Failure "Failed: $projectName (exit code $exitCode)"
                $status = "Failed (exit $exitCode)"
                $failed++
            }

            $results += [PSCustomObject]@{
                TemplateType = $type
                Project      = $projectName
                Status       = $status
            }
        }
    }
}
finally {
    Pop-Location
}

Write-Banner 'Unit Test Summary'
$results | Format-Table -AutoSize

Write-Host "  Executed: $executed" -ForegroundColor Cyan
if ($missing -gt 0) {
    Write-Host "  Missing : $missing" -ForegroundColor Yellow
}
if ($failed -gt 0) {
    Write-Host "  Failed  : $failed" -ForegroundColor Red
}

$shouldFail = $failed -gt 0 -or ($FailOnMissingProject -and $missing -gt 0)
if ($shouldFail) {
    exit 1
}

exit 0




