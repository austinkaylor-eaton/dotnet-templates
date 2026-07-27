# Item.Tests

## About
This project contains unit tests for the **Item** template, including snapshot tests for the builder pattern. The tests are written using **TUnit** and utilize **Microsoft.Testing.Platform** for test execution. 

Each test scenario generates output files that are compared against verified snapshots to ensure template correctness. Every test utilizes the [Templates Testing Tooling API](https://github.com/dotnet/templating/wiki/Templates-Testing-Tooling#api).
## .NET 10 Test Runner Configuration

This test project targets **.NET 10** and uses **Microsoft.Testing.Platform** for the testing runtime, along with **TUnit** as the test framework.

### Why `global.json` is Required

On .NET 10 SDK and later, the traditional `dotnet test` command defaults to a legacy VSTest flow that is no longer compatible with **Microsoft.Testing.Platform**. Running `dotnet test` without opting in results in the following error:

```
Testing with VSTest target is no longer supported by Microsoft.Testing.Platform on .NET 10 SDK and later.
```

### Solution

A `global.json` file in the repository root explicitly opts the project into the new Microsoft.Testing.Platform-based test runner:

```json
{
  "test": {
    "runner": "Microsoft.Testing.Platform"
  }
}
```

This configuration ensures that `dotnet test` uses the modern test execution path and properly discovers and runs all tests.

### Running Tests

After the `global.json` is in place, run tests as normal:

```powershell
dotnet test --project tests/Item.Tests/Item.Tests.csproj
```

For more details on Microsoft.Testing.Platform, see:
- [Microsoft.Testing.Platform Documentation](https://aka.ms/testingplatform)
- [dotnet test Migration Guide](https://aka.ms/dotnet-test)

## Builder Pattern Permutation Coverage

`tests/Item.Tests/Patterns/BuilderTests.cs` validates all 8 symbol permutations for the builder item template by varying only:

- `Namespace`: default/custom
- `ClassName`: default/custom
- `BuilderPrefix`: `With`/`Set`

Scenario names use a stable slug format (for example, `default-namespace-custom-class-set-prefix`) so snapshot paths remain predictable under `tests/Item.Tests/Patterns/Snapshots/`.

## Updating Snapshot Baselines

When template output changes (or when `TemplateVerifierOptions` naming flags change),
the existing snapshot baselines can fail to match expected paths and content.

Use this workflow to regenerate and commit snapshots safely.

### 1) Run tests once to capture the expected snapshot names

```powershell
dotnet test --project tests/Item.Tests/Item.Tests.csproj -v normal
```

If snapshots are out of date, test failures include lines similar to:

- `Received: <name>.received\...`
- `Verified: <name>.verified\...`

Use these names exactly when creating or updating files under:
`tests/Item.Tests/Patterns/Snapshots/`.

### 2) Promote received output to verified baseline

For each failing snapshot:

1. Copy file content from the generated `*.received` path in `local_testing/...`
2. Create or update the matching `*.verified` file under
   `tests/Item.Tests/Patterns/Snapshots/`
3. Keep file content and newline style identical

### 3) Re-run tests until green

```powershell
dotnet test --project tests/Item.Tests/Item.Tests.csproj -v normal
```

### 4) Commit only stable baselines

Commit:

- updated test code (if any)
- updated files under `tests/Item.Tests/Patterns/Snapshots/`

Do not commit `local_testing/` output.

### Common Failure Patterns

- **`New:`** Missing `*.verified` baseline for the expected scenario name
- **`NotEqual` near `[EOF]`:** Usually trailing newline mismatch only
- **Changed naming options:** Flags like
  `DoNotPrependCallerMethodNameToScenarioName` and
  `DoNotPrependTemplateNameToScenarioName` change scenario folder names and may
  require new `*.verified` snapshot folder names

