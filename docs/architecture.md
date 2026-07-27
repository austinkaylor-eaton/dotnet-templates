## Repository Architecture

This repository manages a collection of `dotnet new` templates organized by type (items, projects, solutions). The architecture separates template sources from build artifacts, automation, and documentation to ensure clarity, maintainability, and scalability.

## High-Level Design

The repository follows a **template-centric, lifecycle-driven** model:

- **Templates** are self-contained template units stored in `templates/`
- **Automation** (`automation/`) handles validation, packaging, and distribution
- **Artifacts** (`artifacts/`) stores compiled packages and logs
- **Documentation** (`docs/`) explains conventions, authoring patterns, and the catalog
- **Local testing** (`local_testing/`) provides an isolated sandbox for template development
- **Tests** (`tests/`) provide unit and integration tests of templates, with a separate test project for each type (item, project, solution)

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

Home for template source code.

Current repository state:

- `templates/item/patterns/builder/` — item template root
  - `.template.config/` — template metadata (`template.json`, `dotnetcli.host.json`)
  - `Entity.cs` — template content
- `templates/project/` — reserved for future project templates
- `templates/content/` — package content support files

The packaging project remains `templates/Eaton.AustinKaylor.Templates.csproj`.

### `/automation` — Engineering & Automation

Tooling and CI/CD pipelines:

- **`automation/scripts/`** — PowerShell utilities
  - `install-local.ps1` — Install templates from source to local cache
  - `uninstall-local.ps1` — Remove locally installed templates
  - `validate-templates.ps1` — Smoke-test templates discovered by script conventions
  - `pack-templates.ps1` — Create NuGet package (`.nupkg`)
  - `publish-templates.ps1` — Push to NuGet feed
  - `shared.ps1` — Shared helper functions used by all automation scripts

- **CI workflow location** — `.github/workflows/basic_ci.yml`
  - Current automation focuses on changelog updates after merged PRs
  - Validation, packing, and publishing are currently script-driven/manual

### `/artifacts` — Build Outputs

Non-source artifacts:
- **`artifacts/nuget_packages/`** — Generated `.nupkg` files ready to publish
- **`artifacts/logs/`** — CI/CD logs, test reports, validation output

*Git-ignored for security and size.*

### `/docs` — Documentation

- [template-catalog.md](template-catalog.md) — Master inventory of all templates (name, type, status, version)
- [naming-conventions.md](naming-conventions.md) — Identity, `shortName`, package name rules
- [authoring-guide.md](authoring-guide.md) — How to create a new template
- [release-process.md](release-process.md) — Version, tag, package, publish workflow
- [changelog-automation.md](changelog-automation.md) — PR-driven changelog update flow
- [architecture.md](architecture.md) — This file

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
templates/item/patterns/builder/
  ├── .template.config/
  │   ├── template.json         ← Metadata, symbols, tags
  │   └── dotnetcli.host.json   ← CLI parameter mapping and examples
  └── Entity.cs                 ← Template source (uses symbols)
```

### Key Files

**`template.json`**
- `identity`: Unique full name (`Eaton.AustinKaylor.Templates.Item.Patterns.Builder.CSharp`)
- `shortName`: CLI-friendly name (`eaton-ajk-patterns-builder`)
- `name`: Display name
- `description`: What the template does
- `author`: Creator
- `symbols`: Parameters users can customize
- `tags`: Template language/type metadata used by `dotnet new`

**`dotnetcli.host.json`**
- `symbolInfo`: Friendly names and prompts for `dotnet new` CLI
- `usageExamples`: Common use cases

### Symbols & Replacement

Templates use placeholder syntax:
- `^` prefix for symbols: `^ClassName^`, `^Namespace^`
- Built-in: `name`, `TargetFramework`, `HostIdentifier`
- Custom: author-defined (e.g., `EnableAuth`, `IncludeTests`)

Example:
```csharp
namespace ^Namespace^;

/// <summary>
/// Represents the entity created by the builder pattern.
/// </summary>
public class ^ClassName^
{
}
```

When a user runs `dotnet new eaton-ajk-patterns-builder --name Order --namespace My.App.Models`, the symbols get replaced.

## Template Lifecycle

The architecture supports a simple authoring-to-release workflow:

1. Author templates under `templates/`
2. Validate locally and in CI
3. Package and publish a template pack

For operational details and exact commands, use:

- [authoring-guide.md](authoring-guide.md) for authoring and local validation
- [release-process.md](release-process.md) for versioning, packing, publishing, and tagging

## Canonical Documentation Ownership

To keep this document focused on structure and system design, use these other
documents as the canonical home for operational detail:

- [naming-conventions.md](naming-conventions.md) — template identity, `shortName`, folder names,
  symbol naming, and package naming
- [authoring-guide.md](authoring-guide.md) — how to create templates, define symbols, and test
  generated output
- [release-process.md](release-process.md) — versioning, packaging, publishing, tagging, and
  release validation
- [template-catalog.md](template-catalog.md) — template inventory and lifecycle status values

## CI/CD Pipeline

Current automated workflow:

1. **Changelog update on merge**
   - Implemented in `.github/workflows/basic_ci.yml`
   - Runs `automation/scripts/update-changelog-from-pr.ps1`
   - Commits `CHANGELOG.md` updates when changelog markers are present in the PR body

Current manual/scripted workflow:

2. **Validation** — Run `automation/scripts/validate-templates.ps1`
3. **Packaging** — Run `automation/scripts/pack-templates.ps1`
4. **Publishing** — Run `automation/scripts/publish-templates.ps1`

## Key Design Decisions

### Why Separate `src/` from Template Root?

- **Clarity**: Distinguishes template content from metadata and tests
- **Clean Package**: Only `src/` gets bundled; tests, scripts stay in repo
- **Conventions**: Matches Microsoft template standards

### Why One Package for Multiple Templates?

- **Simpler Distribution**: One `install` command installs all templates
- **Unified Versioning**: All templates ship together, reducing coordination overhead
- **Single Feed Dependency**: Users depend on one package

*Alternative*: Split into separate NuGet packages (`Eaton.AustinKaylor.Templates.Items`, `Eaton.AustinKaylor.Templates.Projects`). Revisit if templates diverge significantly in release cadence.

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
3. Update [docs/template-catalog.md](template-catalog.md) with new row
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

| Task                        | Script                                        | Result                                  |
|-----------------------------|-----------------------------------------------|-----------------------------------------|
| Install locally for testing | `.\automation\scripts\install-local.ps1`      | Templates in local cache                |
| Validate all templates      | `.\automation\scripts\validate-templates.ps1` | Build report, pass/fail                 |
| Create NuGet package        | `.\automation\scripts\pack-templates.ps1`     | `.nupkg` in `artifacts/nuget_packages/` |
| Publish to feed             | `.\automation\scripts\publish-templates.ps1`  | Live on NuGet or internal feed          |
| Uninstall from local cache  | `.\automation\scripts\uninstall-local.ps1`    | Removes local templates                 |

## References

- [Custom templates for dotnet new](https://learn.microsoft.com/en-us/dotnet/core/tools/custom-templates)
- [How to create item templates](https://learn.microsoft.com/en-us/dotnet/core/tutorials/cli-templates-create-item)
- [How to create project templates](https://learn.microsoft.com/en-us/dotnet/core/tutorials/cli-templates-create-project)
- [How to create template packs](https://learn.microsoft.com/en-us/dotnet/core/tutorials/cli-templates-create-template-pack)
- [dotnet/templating wiki](https://github.com/dotnet/templating/wiki)

