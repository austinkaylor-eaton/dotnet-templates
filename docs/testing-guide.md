## Testing Guide

This document describes how to run template unit tests in this repository.
Tests are implemented using [TUnit](https://tunit.dev) and
[Microsoft.Testing.Platform](https://aka.ms/testingplatform).
Test projects live under `tests/`, organized by template type.

## Test Project Organization

| Folder                       | Template Type | Status           |
|------------------------------|---------------|------------------|
| `tests/Item.Tests/`          | item          | Exists           |
| `tests/Project.UnitTests/`   | project       | Not yet created  |
| `tests/Solution.UnitTests/`  | solution      | Not yet created  |

When project and solution test projects are added, the test runner will pick
them up automatically—no script changes required.

## Running Tests

Use the `run-unit-tests.ps1` automation script to run tests from the
repository root. It discovers test projects by template type and produces
TRX and HTML reports under `artifacts/test-results/`.

```powershell
# Run all template types (default)
.\automation\scripts\run-unit-tests.ps1

# Run item tests only
.\automation\scripts\run-unit-tests.ps1 -TemplateType item

# Run multiple explicit types (comma-delimited or array both work)
.\automation\scripts\run-unit-tests.ps1 -TemplateType item,project
.\automation\scripts\run-unit-tests.ps1 -TemplateType @('item', 'project')

# Fail if a requested template type has no test project
.\automation\scripts\run-unit-tests.ps1 -TemplateType item,project -FailOnMissingProject
```

### Filtering Tests

The `-Filter` parameter maps directly to the Microsoft.Testing.Platform
`--filter` argument. TUnit supports filter expressions using:

- `FullyQualifiedName~<partial>` — class or method name contains substring
- `Category=<value>` — matches `[Category]` attribute
- `TestName=<exact>` — exact test display name

```powershell
# Run only tests whose name contains "DefaultInstantiation"
.\automation\scripts\run-unit-tests.ps1 -TemplateType item `
    -Filter "FullyQualifiedName~DefaultInstantiation"

# Run tests tagged with a specific category
.\automation\scripts\run-unit-tests.ps1 -TemplateType item `
    -Filter "Category=Smoke"
```

See [TUnit test filters documentation](https://tunit.dev/docs/execution/test-filters)
for the full filter syntax reference.

### Pass-Through Arguments

Any Microsoft.Testing.Platform argument can be forwarded to the test runner
using `-RunnerArguments`. Examples:

```powershell
# Enable detailed output
.\automation\scripts\run-unit-tests.ps1 -TemplateType item `
    -RunnerArguments @('--output', 'Detailed')

# Repeat every test three times
.\automation\scripts\run-unit-tests.ps1 -TemplateType item `
    -RunnerArguments @('--repeat', '3')
```

### Parameters Reference

| Parameter            | Type       | Default   | Description                                                             |
|----------------------|------------|-----------|-------------------------------------------------------------------------|
| `-TemplateType`      | `string[]` | `all`     | Template types to test: `all`, `item`, `project`, `solution`            |
| `-FailOnMissingProject` | `switch` | `false`  | Exit 1 if a requested type has no test project (default: warn + skip)   |
| `-Filter`            | `string`   | *(none)*  | MTP/TUnit filter expression passed to `--filter`                        |
| `-RunnerArguments`   | `string[]` | *(none)*  | Extra arguments forwarded verbatim to Microsoft.Testing.Platform        |

## Test Output

Each run produces a timestamped folder under `artifacts/test-results/`:

```
artifacts/test-results/
  └── 20260727-120000/
        └── item/
              └── Item.Tests/
                    ├── Item.Tests-windows-net10.0-report.html   ← HTML report
                    └── Item.Tests_net10.0_x64.trx               ← TRX for CI annotations
```

- The `artifacts/test-results/` tree is git-ignored.
- The `artifacts/` root is tracked except for logs and packages.

## Snapshot Tests (Item.Tests)

`Item.Tests` uses `Microsoft.TemplateEngine.Authoring.TemplateVerifier` for
snapshot-based template output verification.
See [`tests/Item.Tests/README.md`](../tests/Item.Tests/README.md) for the full
workflow on updating snapshot baselines.

## CI/CD

Unit tests run automatically on every pull request and `workflow_dispatch` via
the `unit-tests` job in `.github/workflows/basic_ci.yml`.

Key CI behaviors:

- **GitHub summary block** — TUnit automatically writes a collapsible results
  summary to the GitHub Actions job summary using the GitHub reporter
  (`TUNIT_GITHUB_REPORTER_STYLE: collapsible`).
- **Report aggregation** — TUnit aggregates all test-project HTML reports into
  one merged report at `$RUNNER_TEMP/tunit-aggregate/**/merged-report.html`
  (auto-enabled on GitHub Actions, zero config required).
- **TRX artifacts** — Individual per-project TRX files are uploaded as the
  `unit-test-results` artifact.
- **Merged HTML artifact** — The aggregated HTML report is uploaded as the
  `merged-test-report` artifact.
- **PR annotations** — `dorny/test-reporter` converts TRX results into inline
  PR check annotations when TRX files are present.

## Adding Tests for a New Template Type

1. Create the test project under `tests/<Type>.UnitTests/`:

   ```powershell
   dotnet new tunit-project -o tests/Project.UnitTests --name Project.UnitTests
   ```

2. Reference `Microsoft.TemplateEngine.Authoring.TemplateVerifier` and add
   `TUnit` (match the version in `Item.Tests/Item.Tests.csproj`).

3. Add tests following the snapshot pattern in `tests/Item.Tests/Patterns/`.

4. Run locally:

   ```powershell
   .\automation\scripts\run-unit-tests.ps1 -TemplateType project
   ```

5. CI will pick up the new project automatically on the next PR.

## Resources

- [TUnit documentation](https://tunit.dev/docs/intro)
- [TUnit test filters](https://tunit.dev/docs/execution/test-filters)
- [TUnit CI/CD reporting](https://tunit.dev/docs/execution/ci-cd-reporting)
- [TUnit report aggregation](https://tunit.dev/docs/guides/report-aggregation)
- [Microsoft.Testing.Platform documentation](https://aka.ms/testingplatform)
- [`tests/Item.Tests/README.md`](../tests/Item.Tests/README.md) — snapshot update workflow

