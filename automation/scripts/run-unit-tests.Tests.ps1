#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0'; MaximumVersion = '99.99.99' }

<#
.SYNOPSIS
    Pester unit tests for the Resolve-SelectedTemplateTypes function
    defined in run-unit-tests.ps1.

.DESCRIPTION
    Because Resolve-SelectedTemplateTypes is a nested function inside
    run-unit-tests.ps1, it is redefined here verbatim so it can be
    exercised in isolation without triggering the script's top-level
    side-effects (directory creation, dotnet invocations, etc.).

    Run with:
        Invoke-Pester -Path '.\run-unit-tests.Tests.ps1' -Output Detailed
#>

Set-StrictMode -Version Latest

# ---------------------------------------------------------------------------
# Function under test (copied verbatim from run-unit-tests.ps1)
# ---------------------------------------------------------------------------
# Pester 5+ runs It/Context blocks in a child scope, so the function must be
# defined inside BeforeAll so it is available to all nested test blocks.
# ---------------------------------------------------------------------------

BeforeAll {

function Resolve-SelectedTemplateTypes {
    param([string[]]$Requested)

    $expanded = @(
        foreach ($value in $Requested) {
            if ([string]::IsNullOrWhiteSpace($value)) {
                continue
            }

            foreach ($segment in $value.Split(',')) {
                $trimmed = $segment.Trim()
                if (-not [string]::IsNullOrWhiteSpace($trimmed)) {
                    $trimmed
                }
            }
        }
    )

    $allTypes = @('item', 'project', 'solution')
    $allowed = @('all') + $allTypes
    $invalid = @($expanded | Where-Object { $_ -notin $allowed } | Select-Object -Unique)
    if ($invalid.Count -gt 0) {
        throw "Invalid template type value(s): $($invalid -join ', '). Allowed values: all, item, project, solution."
    }

    if ($expanded -contains 'all') {
        return $allTypes
    }

    return $expanded | Select-Object -Unique
}

} # end BeforeAll

# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

Describe 'Resolve-SelectedTemplateTypes' {

    # ------------------------------------------------------------------
    # 'all' expansion
    # ------------------------------------------------------------------

    Context "when 'all' is requested" {

        It "returns item, project, and solution when given 'all'" {
            $result = Resolve-SelectedTemplateTypes -Requested @('all')
            $result | Should -Be @('item', 'project', 'solution')
        }

        It "returns all three types when 'all' appears alongside explicit types" {
            $result = Resolve-SelectedTemplateTypes -Requested @('all', 'item')
            $result | Should -Be @('item', 'project', 'solution')
        }

        It "returns all three types when 'all' is comma-separated with another type" {
            $result = Resolve-SelectedTemplateTypes -Requested @('all,project')
            $result | Should -Be @('item', 'project', 'solution')
        }
    }

    # ------------------------------------------------------------------
    # Single explicit types
    # ------------------------------------------------------------------

    Context "when a single explicit type is requested" {

        It "returns 'item' when given 'item'" {
            $result = Resolve-SelectedTemplateTypes -Requested @('item')
            $result | Should -Be @('item')
        }

        It "returns 'project' when given 'project'" {
            $result = Resolve-SelectedTemplateTypes -Requested @('project')
            $result | Should -Be @('project')
        }

        It "returns 'solution' when given 'solution'" {
            $result = Resolve-SelectedTemplateTypes -Requested @('solution')
            $result | Should -Be @('solution')
        }
    }

    # ------------------------------------------------------------------
    # Multiple explicit types
    # ------------------------------------------------------------------

    Context "when multiple explicit types are requested" {

        It "returns item and project when both are given as separate elements" {
            $result = Resolve-SelectedTemplateTypes -Requested @('item', 'project')
            $result | Should -Be @('item', 'project')
        }

        It "returns item and solution when both are given as separate elements" {
            $result = Resolve-SelectedTemplateTypes -Requested @('item', 'solution')
            $result | Should -Be @('item', 'solution')
        }

        It "returns all three explicit types when all are given as separate elements" {
            $result = Resolve-SelectedTemplateTypes -Requested @('item', 'project', 'solution')
            $result | Should -Be @('item', 'project', 'solution')
        }
    }

    # ------------------------------------------------------------------
    # Comma-separated strings
    # ------------------------------------------------------------------

    Context "when values contain comma-separated types" {

        It "splits a comma-separated string into individual types" {
            $result = Resolve-SelectedTemplateTypes -Requested @('item,project')
            $result | Should -Be @('item', 'project')
        }

        It "splits a comma-separated string with all three types" {
            $result = Resolve-SelectedTemplateTypes -Requested @('item,project,solution')
            $result | Should -Be @('item', 'project', 'solution')
        }

        It "handles spaces around commas in comma-separated strings" {
            $result = Resolve-SelectedTemplateTypes -Requested @('item , project')
            $result | Should -Be @('item', 'project')
        }

        It "splits mixed array elements and comma-separated values" {
            $result = Resolve-SelectedTemplateTypes -Requested @('item,project', 'solution')
            $result | Should -Be @('item', 'project', 'solution')
        }
    }

    # ------------------------------------------------------------------
    # Deduplication
    # ------------------------------------------------------------------

    Context "when duplicate types are requested" {

        It "returns a single 'item' when 'item' is specified twice" {
            $result = Resolve-SelectedTemplateTypes -Requested @('item', 'item')
            $result | Should -Be @('item')
        }

        It "deduplicates types from comma-separated and array sources" {
            $result = Resolve-SelectedTemplateTypes -Requested @('item,project', 'item')
            $result | Should -Be @('item', 'project')
        }
    }

    # ------------------------------------------------------------------
    # Whitespace handling
    # ------------------------------------------------------------------

    Context "when values contain blank or whitespace-only entries" {

        It "skips an empty string element" {
            $result = Resolve-SelectedTemplateTypes -Requested @('', 'item')
            $result | Should -Be @('item')
        }

        It "skips a whitespace-only string element" {
            $result = Resolve-SelectedTemplateTypes -Requested @('   ', 'item')
            $result | Should -Be @('item')
        }

        It "ignores leading and trailing whitespace around a valid type" {
            $result = Resolve-SelectedTemplateTypes -Requested @('  item  ')
            $result | Should -Be @('item')
        }

        It "ignores empty segments produced by trailing commas" {
            $result = Resolve-SelectedTemplateTypes -Requested @('item,')
            $result | Should -Be @('item')
        }
    }

    # ------------------------------------------------------------------
    # Invalid values — error cases
    # ------------------------------------------------------------------

    Context "when invalid type values are requested" {

        It "throws when a single unknown type is given" {
            { Resolve-SelectedTemplateTypes -Requested @('unknown') } |
                Should -Throw -ExpectedMessage '*Invalid template type value(s)*'
        }

        It "throws when an invalid type is mixed with valid types" {
            { Resolve-SelectedTemplateTypes -Requested @('item', 'bad') } |
                Should -Throw -ExpectedMessage '*Invalid template type value(s)*'
        }

        It "throws when an invalid type appears in a comma-separated string" {
            { Resolve-SelectedTemplateTypes -Requested @('item,bad') } |
                Should -Throw -ExpectedMessage '*Invalid template type value(s)*'
        }

        It "includes the invalid value in the exception message" {
            { Resolve-SelectedTemplateTypes -Requested @('bad-type') } |
                Should -Throw -ExpectedMessage '*bad-type*'
        }

        It "lists multiple invalid values in the exception message" {
            { Resolve-SelectedTemplateTypes -Requested @('bad1', 'bad2') } |
                Should -Throw -ExpectedMessage '*bad1*'
        }

        It "accepts a type given in uppercase because PowerShell -notin is case-insensitive" {
            # PowerShell's -notin operator is case-insensitive, so 'Item' matches 'item'.
            $result = Resolve-SelectedTemplateTypes -Requested @('Item')
            $result | Should -Be @('Item')
        }
    }
}





