## Overview
A dotnet 10 controller-based web api template based off of the tutorial https://learn.microsoft.com/en-us/aspnet/core/tutorials/first-web-api?view=aspnetcore-10.0&tabs=visual-studio-code

## CLI Commands
### Create a new web api project using the microsoft template
```bash
dotnet new webapi --use-controllers -o TodoApi
```
### Trust the HTTPs development certificate
```bash
dotnet dev-certs https --trust
```
### Scaffold the TodoItemsController using the ASP.NET Core scaffolding tool
```bash
dotnet aspnet-codegenerator controller -name TodoItemsController -async -api -m TodoItem -dc TodoContext -outDir Controllers
```

## Spectral Linting

The [`RunSpectralLint.ps1`](TodoApi/Scripts/RunSpectralLint.ps1) script installs the
latest [Spectral CLI](https://github.com/stoplightio/spectral/releases), verifies it,
and lints the generated OpenAPI document against the ruleset in
[`.spectral.yml`](TodoApi/.spectral.yml).

**Requirements:** PowerShell 7+ (`pwsh`) and the .NET 10 SDK.

Run from the `FirstApi/` directory (or any location — the script uses `$PSScriptRoot`):

```powershell
./TodoApi/Scripts/RunSpectralLint.ps1
```

**What the script does:**

| Step | Detail |
|------|--------|
| Install (Linux) | Runs the official `install.sh` via `curl` |
| Install (Windows) | Downloads `spectral.exe` from GitHub Releases to `TodoApi/Tools/` |
| Verify | Runs `spectral --version` and fails fast if not found |
| Generate OpenAPI doc | Runs `dotnet build` to produce `TodoApi/TodoApi.json` when absent |
| Lint | Runs `spectral lint TodoApi.json --ruleset .spectral.yml` |

> `TodoApi/Tools/` is excluded from git via `.gitignore`.

## CI Check For OpenAPI Drift

Use [`EnsureOpenApiSpecUpToDate.ps1`](TodoApi/Scripts/EnsureOpenApiSpecUpToDate.ps1)
in CI to fail when `TodoApi.json` is out of date.

```powershell
pwsh -NoProfile -File TodoApi/Scripts/EnsureOpenApiSpecUpToDate.ps1
```

Equivalent raw command sequence:

```powershell
dotnet build TodoApi/TodoApi.csproj --nologo -v minimal
git --no-pager diff --exit-code -- TodoApi/TodoApi.json
```

A non-zero exit code means `TodoApi/TodoApi.json` changed and needs to be committed.

## Links
- [Microsoft Learn Tutorial](https://learn.microsoft.com/en-us/aspnet/core/tutorials/first-web-api?view=aspnetcore-10.0&tabs=visual-studio-code)
- [Microsoft Learn - Best Practices for API Design](https://learn.microsoft.com/en-us/azure/architecture/best-practices/api-design)
- [Lint generated OpenAPI documents with Spectral](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/openapi/using-openapi-documents?view=aspnetcore-10.0#lint-generated-openapi-documents-with-spectral)
- [Use Scalar for interactive API documentation](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/openapi/using-openapi-documents?view=aspnetcore-10.0#use-scalar-for-interactive-api-documentation)
- [Enable XML Documentation in an ASP.NET Core Web API Project](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/openapi/openapi-comments?view=aspnetcore-10.0#enable-xml-documentation-in-an-aspnet-core-api-project)
- [.spectral.yml](https://github.com/stoplightio/spectral#1-create-a-local-ruleset)
- [Include OpenAPI Metadata for Endpoints](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/openapi/include-metadata?view=aspnetcore-10.0&tabs=minimal-apis#include-openapi-metadata-for-endpoints)
- [Open API XML Documentation Comments](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/openapi/openapi-comments?view=aspnetcore-10.0)
- [ASP.NET OpenAPI XML Implementation Notes](https://github.com/captainsafia/aspnet-openapi-xml#implementation-notes)

[Back to Main README](../../README.md)