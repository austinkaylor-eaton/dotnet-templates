# Template Authoring Guide

This guide walks you through creating a new `dotnet new` template from scratch. You'll learn how to structure templates, define symbols, set up metadata, and test them locally before handing the template off to the release process.

## Before You Start

- Review [architecture.md](architecture.md) to understand the repository structure
- Review [naming-conventions.md](naming-conventions.md) to understand template identity and naming
- Review [release-process.md](release-process.md) for versioning, packaging, and publishing responsibilities
- Have the [Microsoft Learn: Create a custom template](https://learn.microsoft.com/en-us/dotnet/core/tools/custom-templates) docs handy
- Decide your template type: 
  - **item**
  - **project**
  - **solution**

## Template Types at a Glance

| Type | Use When | Example |
|------|----------|---------|
| **Item** | Adding a file to an existing project | class, interface, enum, XAML view |
| **Project** | Creating a new `.csproj` with full structure | console app, web API, class library |
| **Solution** | Creating a `.sln` with multiple projects | monolithic app, microservices starter |

## Quick Start: Create an Item Template

### Step 1: Create the Directory Structure

```powershell
# Create folder for your new item template
mkdir templates\item\eaton-mytemplate\src\.template.config
mkdir templates\item\eaton-mytemplate\tests\smoke
mkdir templates\item\eaton-mytemplate\tests\snapshot
```

### Step 2: Create Template Source

Add your template file to `src/`. Use `^Symbol^` syntax for replaceable values:

**File:** `templates/item/eaton-mytemplate/src/MyFile.cs`

```csharp
namespace ^Namespace^;

/// <summary>
/// ^Description^
/// </summary>
public class ^ClassName^
{
    // Your code here
}
```

### Step 3: Create `template.json`

**File:** `templates/item/eaton-mytemplate/src/.template.config/template.json`

```json
{
  "$schema": "http://json.schemastore.org/template",
  "author": "Austin Kaylor",
  "classifications": ["Common"],
  "name": "Eaton Class",
  "identity": "Eaton.Templates.Item.Class.CSharp",
  "shortName": "eaton-class",
  "description": "Creates a new C# class with XML documentation.",
  "tags": {
    "language": "C#",
    "type": "item"
  },
  "baselines": {
    "app": {
      "description": "Target app type",
      "defaultValue": "net8.0"
    }
  },
  "symbols": {
    "Namespace": {
      "type": "parameter",
      "description": "The namespace for the class",
      "datatype": "text",
      "replaces": "^Namespace^",
      "fileRename": "MyFile",
      "defaultValue": "MyNamespace"
    },
    "ClassName": {
      "type": "parameter",
      "description": "The name of the class",
      "datatype": "text",
      "replaces": "^ClassName^",
      "fileRename": "MyFile",
      "defaultValue": "MyClass"
    },
    "Description": {
      "type": "parameter",
      "description": "XML doc summary for the class",
      "datatype": "text",
      "replaces": "^Description^",
      "defaultValue": "A new class"
    }
  }
}
```

### Step 4: Create `dotnetcli.host.json`

**File:** `templates/item/eaton-mytemplate/src/.template.config/dotnetcli.host.json`

```json
{
  "$schema": "http://json.schemastore.org/dotnetcli.host",
  "usageExamples": [
    "dotnet new eaton-class",
    "dotnet new eaton-class --namespace MyApp --class-name User --description \"Represents a user\""
  ],
  "symbolInfo": [
    {
      "id": "Namespace",
      "description": "The namespace for the class",
      "longName": "namespace",
      "shortName": "ns"
    },
    {
      "id": "ClassName",
      "description": "The name of the class",
      "longName": "class-name",
      "shortName": "c"
    },
    {
      "id": "Description",
      "description": "XML doc summary for the class",
      "longName": "description",
      "shortName": "d"
    }
  ]
}
```

### Step 5: Create Local Tests

**File:** `templates/item/eaton-mytemplate/tests/smoke/verify.ps1`

```powershell
# Basic smoke test: verify the generated file contains expected content
param(
    [string]$OutputPath
)

$filePath = Join-Path $OutputPath "MyFile.cs"
if (!(Test-Path $filePath)) {
    Write-Error "Generated file not found at $filePath"
    exit 1
}

$content = Get-Content $filePath -Raw
if ($content -notmatch "public class") {
    Write-Error "Generated file missing expected class declaration"
    exit 1
}

Write-Host "✓ Smoke test passed"
exit 0
```

### Step 6: Create Template README

**File:** `templates/item/eaton-mytemplate/README.md`

Example content:

```text
# Eaton Class Template

Generates a new C# class with XML documentation comments.

## Usage

dotnet new eaton-class --namespace My.App --class-name User --description "A user entity"

## Parameters

| Parameter | Short | Description | Default |
|-----------|-------|-------------|---------|
| `--namespace` | `--ns` | Target namespace | `MyNamespace` |
| `--class-name` | `-c` | Class name | `MyClass` |
| `--description` | `-d` | XML doc summary | `A new class` |

## Generated Files

- `MyFile.cs` — The new class file

## Example Output

namespace My.App;

/// <summary>
/// A user entity
/// </summary>
public class User
{
    // Your code here
}
```

### Step 7: Test Locally

```powershell
# Install the template to your local cache
.\automation\scripts\install-local.ps1

# Create a test project to generate into
New-Item -ItemType Directory -Path .\local_testing\test-eaton-class -Force
Set-Location .\local_testing\test-eaton-class

# Create a dummy project structure
dotnet new classlib -n TestApp
Set-Location .\TestApp

# Generate the template
dotnet new eaton-class --namespace TestApp --class-name MyEntity --description "Test entity"

# Verify the generated file
Get-Content .\MyEntity.cs

# Clean up
Set-Location ..\..\..
```

---

## Deep Dive: Project Templates

Project templates are more complex because they scaffold entire project structures with `.csproj` and dependencies.

### Directory Structure for Project Templates

```
templates/project/eaton-webapi/
  ├── src/
  │   ├── Eaton.WebApi.csproj
  │   ├── Program.cs
  │   ├── appsettings.json
  │   ├── appsettings.Development.json
  │   ├── Properties/
  │   │   └── launchSettings.json
  │   ├── Controllers/
  │   │   └── HealthController.cs
  │   └── .template.config/
  │       ├── template.json
  │       ├── dotnetcli.host.json
  │       ├── post-actions.json (optional)
  │       └── ide.host.json (optional)
  ├── tests/
  │   ├── restore-build.ps1
  │   └── integration.ps1
  └── README.md
```

### Example: ASP.NET Core Minimal API Template

**File:** `templates/project/eaton-webapi/src/.template.config/template.json`

```json
{
  "$schema": "http://json.schemastore.org/template",
  "author": "Austin Kaylor",
  "classifications": ["Web"],
  "name": "Eaton Web API",
  "identity": "Eaton.Templates.Project.WebApi.CSharp",
  "groupIdentity": "Eaton.Templates.Project.WebApi.CSharp",
  "shortName": "eaton-webapi",
  "description": "Creates a minimal ASP.NET Core Web API with health checks.",
  "tags": {
    "language": "C#",
    "type": "project"
  },
  "shortNameAliases": [
    "webapi"
  ],
  "defaultName": "WebApi",
  "preferNameDirectory": true,
  "postActions": [
    {
      "id": "restore",
      "description": "Restore NuGet packages",
      "actionId": "210D431B-A78B-4D2F-B762-4ED3E3EA9025",
      "args": "",
      "continueOnError": false
    }
  ],
  "symbols": {
    "TargetFrameworkVersion": {
      "type": "parameter",
      "description": "The target framework version",
      "datatype": "choice",
      "choices": [
        {
          "choice": "net8.0",
          "description": ".NET 8"
        },
        {
          "choice": "net9.0",
          "description": ".NET 9"
        }
      ],
      "replaces": "net8.0",
      "defaultValue": "net8.0"
    },
    "EnableHealthChecks": {
      "type": "parameter",
      "datatype": "bool",
      "description": "Include health check endpoints",
      "defaultValue": "true"
    },
    "ProjectNamespaceUri": {
      "type": "derived",
      "valueSource": "name",
      "valueTransform": "ValueTransform::PascalCase",
      "replaces": "Eaton.WebApi"
    }
  }
}
```

### Important Keys for Project Templates

| Key | Purpose | Example |
|-----|---------|---------|
| `shortNameAliases` | Alternative short names users can type | `["webapi", "api"]` |
| `defaultName` | Default project name if not specified | `"WebApi"` |
| `preferNameDirectory` | Create a directory with the project name | `true` |
| `postActions` | Commands to run after generation (restore, build, open) | See next section |
| `symbols` | Parameters with types: `parameter`, `derived`, `computed` | |

### Post-Actions: Auto-Restore and Beyond

Post-actions run automatically after template generation. Common IDs:

| Action ID | Purpose |
|-----------|---------|
| `210D431B-A78B-4D2F-B762-4ED3E3EA9025` | Restore NuGet packages |
| `84C0DA21-51C8-4541-9940-6E8CD9A4BA15` | Open file in IDE |
| `D396213F-92CE-59FB-992D-D39272900B70` | Open folder in IDE |

**File:** `templates/project/eaton-webapi/src/.template.config/post-actions.json` (optional; can inline in `template.json`)

```json
[
  {
    "id": "restore",
    "description": "Restore NuGet packages",
    "actionId": "210D431B-A78B-4D2F-B762-4ED3E3EA9025",
    "args": "",
    "continueOnError": false
  }
]
```

### Conditional Inclusion with Symbols

Use `IncludeInOutput` to conditionally generate files based on symbol values.

**File:** `templates/project/eaton-webapi/src/.template.config/template.json`

```json
{
  "symbols": {
    "IncludeHealthChecks": {
      "type": "parameter",
      "datatype": "bool",
      "defaultValue": "true"
    }
  },
  "sources": [
    {
      "include": ["**/*"],
      "exclude": ["**/bin/**", "**/obj/**"],
      "modifiers": [
        {
          "condition": "(!IncludeHealthChecks)",
          "exclude": ["**/HealthController.cs"]
        }
      ]
    }
  ]
}
```

---

## Symbol Types and Transformations

### Parameter Symbols

User-supplied values:

```json
{
  "MyParam": {
    "type": "parameter",
    "datatype": "text",
    "description": "A user-supplied string",
    "replaces": "^MyParam^",
    "defaultValue": "SomeValue"
  }
}
```

**Data Types:**
- `text` — String value
- `choice` — Enum with predefined options
- `bool` — True/false

### Derived Symbols

Computed from other values:

```json
{
  "ProjectNamespaceUri": {
    "type": "derived",
    "valueSource": "name",
    "valueTransform": "ValueTransform::PascalCase",
    "replaces": "^ProjectNamespaceUri^"
  }
}
```

**Common Transforms:**
- `ValueTransform::PascalCase` — `myProject` → `MyProject`
- `ValueTransform::KebabCase` — `MyProject` → `my-project`
- `ValueTransform::LowerCase` — `MyProject` → `myproject`
- `ValueTransform::SnakeCase` — `MyProject` → `my_project`
- `ValueTransform::SanitizeFileName` — Remove invalid filename chars

### Built-In Symbols

Templates have automatic symbols:

| Symbol            | Value                                                  |
|-------------------|--------------------------------------------------------|
| `name`            | Project or item name (from `--name` or positional arg) |
| `HostIdentifier`  | `dotnet` for CLI, `vs` for Visual Studio               |
| `TargetFramework` | e.g., `net8.0`                                         |

---

## Best Practices

### 1. Use Clear, Descriptive Symbol Names

Use [naming-conventions.md](naming-conventions.md) as the canonical source for naming rules. This
section summarizes the authoring implications of those rules.

**Good:**
```json
{
  "ClassName": { "replaces": "^ClassName^" },
  "Namespace": { "replaces": "^Namespace^" }
}
```

**Avoid:**
```json
{
  "cn": { "replaces": "^cn^" },
  "ns": { "replaces": "^ns^" }
}
```

### 2. Provide Sensible Defaults

Always set `defaultValue` so users can run `dotnet new eaton-class` without parameters:

```json
{
  "ClassName": {
    "type": "parameter",
    "defaultValue": "MyClass"
  }
}
```

### 3. Clean Template Source

**Remove before publishing:**
- `bin/` and `obj/` directories
- `.vs/` and `.vscode/` settings
- `.user` project files
- Stale build artifacts

```powershell
# Clean script example
Remove-Item -Recurse -Force bin, obj, .vs, .vscode
Remove-Item -Force *.user
```

### 4. Use Short Names Consistently

Follow the naming convention from [naming-conventions.md](naming-conventions.md): `eaton-<name>`

- `eaton-class` ✓
- `eaton-interface` ✓
- `eaton-webapi` ✓
- `AustiKaylorClass` ✗
- `class-template` ✗

### 5. Document Symbol Meanings

In `dotnetcli.host.json`, explain what each parameter does:

```json
{
  "symbolInfo": [
    {
      "id": "EnableAuth",
      "description": "Include JWT authentication middleware",
      "longName": "enable-auth",
      "shortName": "auth"
    }
  ]
}
```

### 6. Test File Renaming

When templates generate files, ensure `fileRename` is set so the file name changes:

```json
{
  "ClassName": {
    "type": "parameter",
    "fileRename": "MyClass",
    "replaces": "^ClassName^"
  }
}
```

If you don't set `fileRename`, all generated files will be named literally (e.g., `^ClassName^.cs`).

### 7. Avoid Hardcoded Paths and Versions

**Bad:**
```xml
<TargetFramework>net8.0</TargetFramework>
<PackageReference Include="Serilog" Version="3.0.1" />
```

**Good:**
```xml
<TargetFramework>^TargetFramework^</TargetFramework>
<PackageReference Include="Serilog" Version="3.*" />
```

---

## Testing Your Template

### Local Install and Test

```powershell
# 1. Install template from source
.\automation\scripts\install-local.ps1

# 2. List installed templates
dotnet new list

# 3. Test generation with defaults
New-Item -ItemType Directory -Path .\local_testing\my-test -Force
Set-Location .\local_testing\my-test
dotnet new eaton-class
dotnet build  # if applicable

# 4. Test with custom parameters
dotnet new eaton-class --namespace My.App --class-name User

# 5. Verify output
Get-Content .\MyClass.cs

# 6. Uninstall when done
Set-Location ..\..
.\automation\scripts\uninstall-local.ps1
```

### Automated Smoke Tests

Create a `tests/smoke/verify.ps1` script to validate template generation:

```powershell
param(
    [string]$OutputPath,
    [string]$TemplateParams = ""
)

# Generate template
dotnet new eaton-class -o $OutputPath @TemplateParams

# Verify files exist
$file = Join-Path $OutputPath "MyFile.cs"
if (!(Test-Path $file)) {
    Write-Error "Template file not generated"
    exit 1
}

# Verify content
$content = Get-Content $file -Raw
if ($content -notmatch "public class") {
    Write-Error "Generated file has incorrect structure"
    exit 1
}

Write-Host "✓ Template validation passed"
exit 0
```

### Integration Tests for Projects

```powershell
# Test that generated project restores and builds
param([string]$OutputPath)

# Generate project
dotnet new eaton-webapi -o $OutputPath

# Restore and build
Set-Location $OutputPath
$buildResult = dotnet build 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed: $buildResult"
    exit 1
}

Write-Host "✓ Build and restore passed"
exit 0
```

---

## Common Pitfalls and Solutions

### Issue: Symbols Not Replacing

**Symptoms:** Generated files contain literal `^SymbolName^` text.

**Causes:**
- Symbol key doesn't match placeholder in template
- `fileRename` is set but `replaces` is missing
- CSPROJ file has symbol replaces but text files don't

**Solution:** Ensure every `^Symbol^` in template files has a matching entry in `template.json` with `replaces`:

```json
{
  "ClassName": {
    "type": "parameter",
    "replaces": "^ClassName^"
  }
}
```

The `replaces` value must match the placeholder in the template exactly.

### Issue: File Names Not Changing

**Symptoms:** Generated files are named `MyFile.cs` instead of `User.cs`.

**Cause:** Missing `fileRename` in symbol definition.

**Solution:** Add `fileRename` to identify the base name to replace:

```json
{
  "ClassName": {
    "type": "parameter",
    "fileRename": "MyFile",
    "replaces": "^ClassName^"
  }
}
```

The `fileRename` value must match the base file name used in the template.

### Issue: Help Not Showing Parameters

**Symptoms:** `dotnet new eaton-class --help` doesn't show custom parameters.

**Cause:** Missing `dotnetcli.host.json` or incorrect `symbolInfo` entries.

**Solution:** Add complete `symbolInfo` array with all parameters:

```json
{
  "symbolInfo": [
    {
      "id": "ClassName",
      "description": "The class name",
      "longName": "class-name",
      "shortName": "c"
    }
  ]
}
```

---

## Checklist: Before Opening a Release-Ready Pull Request

- [ ] Template structure is organized (`src/`, `.template.config/`, `tests/`, `README.md`)
- [ ] `template.json` is valid JSON (use jsonlint or IDE)
- [ ] All symbols have `replaces` matching placeholders in template
- [ ] File-renaming symbols have `fileRename` set
- [ ] `dotnetcli.host.json` has `symbolInfo` for all parameters
- [ ] Default values are sensible
- [ ] Template source is clean (no `bin/`, `obj/`, `.user` files)
- [ ] Local tests pass: `.\automation\scripts\validate-templates.ps1`
- [ ] README documents all parameters and shows example usage
- [ ] Naming follows [naming-conventions.md](naming-conventions.md)
- [ ] Description is clear and concise
- [ ] Post-actions (if any) are tested

For packaging, versioning, publishing, and tagging, follow
[release-process.md](release-process.md).

---

## Next Steps

1. **Author your template** using the steps above
2. **Test locally** with `.\automation\scripts\install-local.ps1`
3. **Validate** with `.\automation\scripts\validate-templates.ps1`
4. **Document** in [template-catalog.md](template-catalog.md)
5. **Update [CHANGELOG.md](../CHANGELOG.md)** with your new template
6. **Commit and create PR** for review

---

## Resources

- [Microsoft Learn: Create custom templates](https://learn.microsoft.com/en-us/dotnet/core/tools/custom-templates)
- [Microsoft Learn: Create item templates](https://learn.microsoft.com/en-us/dotnet/core/tutorials/cli-templates-create-item)
- [Microsoft Learn: Create project templates](https://learn.microsoft.com/en-us/dotnet/core/tutorials/cli-templates-create-project)
- [dotnet/templating GitHub Wiki](https://github.com/dotnet/templating/wiki)
- [Template.json Schema](http://json.schemastore.org/template)
- [dotnetcli.host.json Schema](http://json.schemastore.org/dotnetcli.host)

