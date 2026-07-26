# Item.Tests

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

