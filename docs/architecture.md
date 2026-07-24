## Repository Architecture

This repository manages a collection of `dotnet new` templates organized by type (items, projects, solutions). The architecture separates template sources from build artifacts, automation, and documentation to ensure clarity, maintainability, and scalability.

## High-Level Design

The repository follows a **template-centric, lifecycle-driven** model:

- **Templates** are self-contained units stored in `templates/` with configuration and tests
- **Automation** (`automation/`) handles validation, packaging, and distribution
- **Artifacts** (`artifacts/`) stores compiled packages and logs
- **Documentation** (`docs/`) explains conventions, authoring patterns, and the catalog
- **Local testing** (`local_testing/`) provides an isolated sandbox for template development

```
┌─────────────────────────────────────────┐
│  User: dotnet new list / dotnet new <name>
└─────────────────┬───────────────────────┘
                  │
          ┌───────▼────────┐
          │   NuGet Feed   │ (published packages)
          │ (Eaton.Austin  │
          │   Kaylor.      │
          │  Templates)    │
          └───────┬────────┘
                  │
          ┌───────▼────────────┐
          │   Pack & Publish   │ (automation/scripts)
          └───────┬────────────┘
                  │
          ┌───────▼────────────┐
          │   Validate & Test  │ (automation/scripts)
          └───────┬────────────┘
                  │
          ┌───────▼────────────────────┐
          │  Template Sources          │
          │  (templates/item|project)  │
          └────────────────────────────┘
```

## Repository Structure

### `/templates` — Template Sources

Home for all template source code, organized by lifecycle stage and type:

#### `templates/item/`
Item templates (files that inject into existing projects):
- `templates/item/<name>/src/` — Template source files
- `templates/item/<name>/.template.config/` — Metadata (`template.json`)
- `templates/item/<name>/tests/` — Validation tests (smoke, snapshot)
- `templates/item/<name>/README.md` — Usage, parameters, examples

**Example:** `eaton-class/` generates a new C# class with comments.

#### `templates/project/`
Project templates (generate new `.csproj` + associated files):
- `templates/project/<name>/src/` — Full project structure
- `templates/project/<name>/.template.config/` — Metadata
- `templates/project/<name>/tests/` — Build/restore verification
- `templates/project/<name>/README.md` — Usage guide

**Example:** `eaton-webapi/` scaffolds an ASP.NET Core minimal API project.

#### `templates/solution/` (future)
Solution templates (generate `.sln` + multi-project structure).

### `/automation` — Engineering & Automation

Tooling and CI/CD pipelines:

- **`automation/scripts/`** — PowerShell utilities
  - `install-local.ps1` — Install templates from source to local cache
  - `uninstall-local.ps1` — Remove locally installed templates
  - `validate-templates.ps1` — Smoke-test all templates (generate, build, restore)
  - `pack-templates.ps1` — Create NuGet package (`.nupkg`)
  - `publish-templates.ps1` — Push to NuGet feed
  - `Directory.Build.props` — Shared project configuration
  - `version.json` — Version definition for all templates

- **`automation/ci/`** — Continuous integration pipelines
  - GitHub Actions workflows, Azure Pipelines, etc.
  - Triggered on PR/push to validate, pack, and optionally publish

### `/artifacts` — Build Outputs

Non-source artifacts:
- **`artifacts/nupkgs/`** — Generated `.nupkg` files ready to publish
- **`artifacts/logs/`** — CI/CD logs, test reports, validation output

*Git-ignored for security and size.*

### `/docs` — Documentation

- **`template-catalog.md`** — Master inventory of all templates (name, type, status, version)
- **`naming-conventions.md`** — Identity, `shortName`, package name rules
- **`authoring-guide.md`** — How to create a new template
- **`release-process.md`** — Version, tag, package, publish workflow
- **`architecture.md`** — This file

### `/local_testing` — Sandbox

Isolated folder for testing template output. **Git-ignored** to prevent accidental commits.

Use this to:
- Generate from templates and verify output
- Run `dotnet build` / `dotnet test` on generated projects
- Test parameter replacement and symbol generation

### `/` — Root Level

- **`README.md`** — Quick start and links to Microsoft Learn tutorials
- **`CHANGELOG.md`** — Semantic version history and release notes
- **`Eaton.AustinKaylor.Templates.slnx`** — File explorer structure (not a build artifact)
- **`Eaton.AustinKaylor.Templates.sln.DotSettings.user`** — IDE settings (git-ignored)
- **`.gitignore`** — Excludes build outputs, IDE files, `local_testing/`

## Template Anatomy

Each template follows a predictable structure:

```
templates/item/eaton-class/
  ├── src/
  │   ├── .template.config/
  │   │   ├── template.json         ← Metadata, symbols, hooks
  │   │   └── dotnetcli.host.json   ← CLI hosting config
  │   ├── Class.cs                  ← Template source (uses symbols)
  │   └── _readme.md                ← Optional: visible after template runs
  ├── tests/
  │   ├── smoke/                    ← Basic generation + build test
  │   └── snapshot/                 ← Output comparison tests
  └── README.md                      ← Authoring guide for this template
```

### Key Files

**`template.json`**
- `identity`: Unique full name (`Eaton.Templates.Item.Class.CSharp`)
- `shortName`: CLI-friendly name (`eaton-class`)
- `name`: Display name
- `description`: What the template does
- `author`: Creator
- `baselines`: Target frameworks (`.NET 8`, `.NET 9`, etc.)
- `symbols`: Parameters users can customize
- `postActions`: Commands to run after generation (e.g., `dotnet restore`)

**`dotnetcli.host.json`**
- `symbolInfo`: Friendly names and prompts for `dotnet new` CLI
- `usageExamples`: Common use cases

### Symbols & Replacement

Templates use placeholder syntax:
- `^` prefix for symbols: `^ClassName^`, `^Namespace^`
- Built-in: `ProjectName`, `TargetFramework`, `HostIdentifier`
- Custom: author-defined (e.g., `EnableAuth`, `IncludeTests`)

Example:
```csharp
namespace ^Namespace^;

/// <summary>
/// ^Description^
/// </summary>
public class ^ClassName^
{
}
```

When a user runs `dotnet new eaton-class --namespace My.App --classname User --description "User entity"`, the symbols get replaced.

## Template Lifecycle

### 1. **Authoring**
- Create new folder in `templates/item/` or `templates/project/`
- Write template source in `src/`
- Add `template.json` and `dotnetcli.host.json` to `src/.template.config/`
- Add tests to `tests/`
- Create `README.md` with usage examples

### 2. **Local Testing**
```powershell
# Install to local cache
.\automation\scripts\install-local.ps1

# Generate in local_testing/
cd local_testing
dotnet new eaton-class --help
dotnet new eaton-class --namespace My.App --classname Foo

# Verify output, build, test
dotnet build
```

### 3. **Validation**
```powershell
# Run smoke tests
.\automation\scripts\validate-templates.ps1
```

Validates:
- Template JSON syntax
- Symbol replacement works
- Generated projects restore and build
- No stale binaries in template source

### 4. **Versioning & Documentation**
- Update `CHANGELOG.md` (semver: major.minor.patch)
- Add entry to `docs/template-catalog.md` with status and package version
- Commit and create git tag (e.g., `v1.0.0`)

### 5. **Packaging**
```powershell
# Pack all templates into .nupkg
.\automation\scripts\pack-templates.ps1
```

Creates `artifacts/nupkgs/Eaton.AustinKaylor.Templates.1.0.0.nupkg` containing:
- All template sources
- Configuration metadata
- License, readme

### 6. **Publishing**
```powershell
# Push to NuGet or internal feed
.\automation\scripts\publish-templates.ps1
```

Once published, users can install:
```powershell
dotnet new install Eaton.AustainKaylor.Templates
dotnet new eaton-class --help
```

## Naming & Identity Convention

To keep the CLI clean and distinguish templates:

| Aspect | Pattern | Example |
|--------|---------|---------|
| **Full Identity** | `Eaton.Templates.<Type>.<Name>.CSharp` | `Eaton.Templates.Item.Class.CSharp` |
| **Short Name** | kebab-case, CLI-friendly | `eaton-class` |
| **Package ID** | NuGet feed name | `Eaton.AustainKaylor.Templates` |
| **Group Identity** | Same for variants | `Eaton.Templates.Project.WebApi.CSharp` |

See `docs/naming-conventions.md` for details.

## Versioning Strategy

- **Semantic Versioning**: `MAJOR.MINOR.PATCH`
  - **MAJOR**: Breaking changes to template output or symbols
  - **MINOR**: New templates added, new optional symbols
  - **PATCH**: Bug fixes, internal cleanup
  
- **Package Version**: Single version for entire package (`Eaton.AustainKaylor.Templates`)
- **Release Notes**: Documented in `CHANGELOG.md` and GitHub releases

See `docs/release-process.md` for detailed workflow.

## CI/CD Pipeline

Triggered on every commit to `main`:

1. **Validation** — Run `validate-templates.ps1`
   - Check template.json syntax
   - Generate test projects
   - Verify builds succeed
   - Report failures

2. **Packaging** — Run `pack-templates.ps1`
   - Embed version from `automation/version.json`
   - Create `.nupkg` in `artifacts/nupkgs/`

3. **Publishing** (manual or scheduled)
   - Push `.nupkg` to NuGet or internal feed
   - Tag repository
   - Update GitHub releases

## Key Design Decisions

### Why Separate `src/` from Template Root?

- **Clarity**: Distinguishes template content from metadata and tests
- **Clean Package**: Only `src/` gets bundled; tests, scripts stay in repo
- **Conventions**: Matches Microsoft template standards

### Why One Package for Multiple Templates?

- **Simpler Distribution**: One install command installs all
- **Unified Versioning**: All templates ship together, reducing coordination overhead
- **Single Feed Dependency**: Users depend on one package

*Alternative*: Split into separate NuGet packages (`Eaton.AustainKaylor.Templates.Item`, `Eaton.AustainKaylor.Templates.Project`). Revisit if templates diverge significantly in release cadence.

### Why Local Testing Folder?

- **Isolation**: Prevents accidental commits of test output
- **Safe Sandbox**: Authors can test freely without cluttering repo
- **Git-Ignored**: Large binaries don't bloat history

### Why Centralized Scripts?

- **Single Source of Truth**: All templates use same validation/pack/publish logic
- **Consistency**: Reduces risk of templates slipping through validation
- **Maintainability**: Update once, all templates benefit

## Extension Points

### Adding a New Template Type (Solution Templates)

1. Create `templates/solution/` directory
2. Add first solution template: `templates/solution/<name>/src/.template.config/template.json`
3. Update `docs/template-catalog.md` with new row
4. Update `validate-templates.ps1` to include solution templates

### Adding Pre-Release Versions

Add suffix to `automation/version.json`:
```json
{ "version": "1.1.0-beta.1" }
```

NuGet handles pre-release automatically; document in `CHANGELOG.md`.

### Adding CI/CD Workflows

- **GitHub Actions**: Add `.github/workflows/` files
- **Azure Pipelines**: Add `automation/ci/azure-pipelines.yml`
- Template validation and publishing steps are reusable

## Quick Reference

| Task | Script | Result |
|------|--------|--------|
| Install locally for testing | `.\automation\scripts\install-local.ps1` | Templates in local cache |
| Validate all templates | `.\automation\scripts\validate-templates.ps1` | Build report, pass/fail |
| Create NuGet package | `.\automation\scripts\pack-templates.ps1` | `.nupkg` in `artifacts/nupkgs/` |
| Publish to feed | `.\automation\scripts\publish-templates.ps1` | Live on NuGet or internal feed |
| Uninstall from local cache | `.\automation\scripts\uninstall-local.ps1` | Removes local templates |

## References

- [Custom templates for dotnet new](https://learn.microsoft.com/en-us/dotnet/core/tools/custom-templates)
- [How to create item templates](https://learn.microsoft.com/en-us/dotnet/core/tutorials/cli-templates-create-item)
- [How to create project templates](https://learn.microsoft.com/en-us/dotnet/core/tutorials/cli-templates-create-project)
- [How to create template packs](https://learn.microsoft.com/en-us/dotnet/core/tutorials/cli-templates-create-template-pack)
- [dotnet/templating wiki](https://github.com/dotnet/templating/wiki)

