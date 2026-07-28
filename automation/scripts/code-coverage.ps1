[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'shared.ps1')

#Push-Location
#Set-Location $PSScriptRoot/../../tests/Item.Tests
#dotnet build
#dotnet tool install -g dotnet-coverage
#dotnet-coverage collect --output coverage.cobertura.xml --output-format cobertura "dotnet run --no-build"
#dotnet tool install -g dotnet-reportgenerator-globaltool
#reportgenerator -reports:coverage.cobertura.xml -targetdir:coveragereport -reporttypes:MarkdownSummaryGithub
#Pop-Location

## Generate .coverage file from Item.Tests project - output to default directory
#dotnet run --project "tests\Item.Tests\Item.Tests.csproj" --configuration Release --coverage
#
## Generate .coverage file from Item.Tests project - output to specific directory
#dotnet run --project "tests\Item.Tests\Item.Tests.csproj" --configuration Release --coverage --coverage-output ../../../../TestResults/item.coverage
#
## Step 1: Convert .coverage to Cobertura XML
#dotnet-coverage merge ../../../../TestResults/item.coverage --output tests/Item.Tests/TestResults/coverage.cobertura.xml --output-format cobertura
#
## Step 2: Install ReportGenerator (if not already installed)
#dotnet tool install -g dotnet-reportgenerator-globaltool
#
## Step 3: Generate HTML report
#reportgenerator -reports:tests/Item.Tests/TestResults/coverage.cobertura.xml -targetdir:tests/Item.Tests/TestResults/ -reporttypes:Html
#reportgenerator -reports:tests/Item.Tests/TestResults/coverage.cobertura.xml -targetdir:tests/Item.Tests/TestResults/ -reporttypes:MarkdownSummaryGithub



Write-Banner "Code Coverage Report Generation"

Write-Step "Getting repository root, timestamp, and current package version"
$repoRoot = Get-RepoRoot
$timestamp = Get-Date -Format 'yyyyMMddHHmmss'
$packageVersion = Get-PackageVersion
Write-Debug "Current Package Version: $packageVersion"

Write-Step "Getting artifacts\test-results path"
$coverageOutputDir = Join-Path (Get-ArtifactsRoot) "test-results"
Write-Debug "Code Coverage Output Directory: $coverageOutputDir"

Write-Step "Getting unit test project path"
$itemUnitTestProject = Join-Path $repoRoot 'tests\Item.Tests\Item.Tests.csproj'
Write-Debug "Item Unit Test Project Path: $itemUnitTestProject"

Write-Step "Generating Code Coverage Report for $itemUnitTestProject"
$xmlCodeCoveragePath = Join-Path $coverageOutputDir "item.tests.coverage.cobertura.xml"
Write-Info "Building $itemUnitTestProject..."
dotnet build $itemUnitTestProject -c Release
Write-Info "Running unit tests with code coverage..."
#dotnet run --project $itemUnitTestProject --configuration Release --coverage --coverage-output $coverageOutputDir/item.tests.coverage
dotnet-coverage collect --output $xmlCodeCoveragePath --output-format cobertura "dotnet run --no-build --project $itemUnitTestProject --configuration Release"
Write-Success "Code coverage report generated at:$xmlCodeCoveragePath"

# Write-Step "Converting code coverage report to Cobertura format..."
# dotnet-coverage merge $coverageOutputDir/item.tests.coverage --output $coverageOutputDir/coverage.cobertura.xml --output-format cobertura
# Write-Success "Code coverage report at $coverageOutputDir converted to Cobertura format"

Write-Step "Generate Markdown Summary from Code Coverage Report"
reportgenerator -reports:$xmlCodeCoveragePath `
                        -targetdir:$coverageOutputDir `
                        -reporttypes:MarkdownSummaryGithub `
                        -assemblyfilters:"+Item.Tests;-Argon;-xunit*;-Microsoft.*;-System.*"
Write-Success "Markdown summary generated from code coverage report"

