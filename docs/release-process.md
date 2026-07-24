## Release Process

This document defines how template changes move from local development to a
published template package. It is intended to keep releases repeatable,
auditable, and easy to automate as the repository grows.

## Goals

- Release templates with predictable versioning
- Validate template quality before publishing
- Keep package metadata, docs, and changelog in sync
- Support both manual releases and future CI/CD automation
- Minimize the risk of publishing broken or incomplete templates

## Current Repository State

The repository already contains the release-related folders used by the planned
workflow:

- [automation/ci/](../automation/ci/)
- [automation/scripts/](../automation/scripts/)
- [artifacts/logs/](../artifacts/logs/)
- [artifacts/nuget_packages/](../artifacts/nuget_packages/)
- [local_testing/](../local_testing/)

The scripts in [automation/scripts/](../automation/scripts/) implement the workflow described in this
document. See the script file headers for parameter documentation and usage
examples.

## Release Artifacts

Each release should produce the following outputs:

| Artifact        | Location                                                    | Purpose                       |
|-----------------|-------------------------------------------------------------|-------------------------------|
| NuGet package   | `[artifacts/nuget_packages/](../artifacts/nuget_packages/)` | Installable template pack     |
| Validation logs | `[artifacts/logs/](../artifacts/logs/)`                     | Test and packaging output     |
| Changelog entry | `[CHANGELOG.md](../CHANGELOG.md)`                           | Human-readable release notes  |
| Catalog updates | `[docs/template-catalog.md](../docs/template-catalog.md)`   | Template inventory by version |
| Git tag         | repository tag                                              | Immutable version reference   |

## Versioning Policy

This repository uses semantic versioning:

```text
MAJOR.MINOR.PATCH
```

### When to Bump Each Part

| Version Part | Use When                                                        | Examples                                                                           |
|--------------|-----------------------------------------------------------------|------------------------------------------------------------------------------------|
| `MAJOR`      | A change is breaking for consumers                              | Renamed symbols, removed template, changed generated structure in a disruptive way |
| `MINOR`      | A release adds functionality without breaking existing usage    | New template, new optional parameter, new non-breaking baseline                    |
| `PATCH`      | A release fixes issues without adding significant functionality | README fixes, template bug fix, packaging cleanup                                  |

### Breaking Change Guidance

Treat these as breaking changes unless you have a clear compatibility story:

- Removing a template from the package
- Renaming a `shortName`
- Renaming a symbol used by consumers
- Changing generated project layout in a way that breaks onboarding material
- Removing files that downstream automation expects

### Pre-Release Versions

Use pre-release suffixes for templates that should be tested before general
availability:

```text
1.2.0-beta.1
1.2.0-rc.1
```

Use pre-release packages for:

- early access to new templates
- large refactors to existing templates
- validation of packaging or install behavior

## Release Package Identity

The primary template package ID is:

```text
Eaton.AustinKaylor.Templates
```

This package should remain stable over time so users can install and upgrade it
without learning a new package name.

## Release Triggers

Start a release when one or more of the following are true:

- A new template is ready for users
- A template bug fix is complete and validated
- Documentation and packaging updates need to be published together
- A scheduled release window has been reached
- A pre-release package needs to be promoted to a stable release

## Release Roles and Responsibilities

For a small repository, one maintainer may perform all of these steps. As the
repo grows, split responsibilities logically.

| Role               | Responsibilities                                              |
|--------------------|---------------------------------------------------------------|
| Template author    | Implement template changes, add tests, update template README |
| Reviewer           | Verify correctness, naming, docs, and release readiness       |
| Release maintainer | Choose version, update changelog, package, publish, tag       |

## End-to-End Release Workflow

Use this checklist for every release.

### 1. Confirm Scope

Identify what is included in the release:

- new templates
- template fixes
- documentation updates
- packaging or automation changes

Capture the intended version bump before making release edits.

### 2. Verify Template Readiness

Before packaging, each changed template should have:

- a valid `.template.config/template.json`
- a clear `name`, `identity`, `groupIdentity`, and `shortName`
- a per-template `README.md`
- local validation coverage
- no stale `bin/`, `obj/`, `.vs/`, `.user`, or generated output checked in

Cross-check:

- [docs/naming-conventions.md](naming-conventions.md)
- [docs/authoring-guide.md](authoring-guide.md)
- [docs/architecture.md](architecture.md)

### 3. Run Local Validation

Validate the changed templates locally before creating a release commit.

Expected future commands:

```powershell
.\automation\scripts\install-local.ps1
.\automation\scripts\validate-templates.ps1
```

At minimum, validate these behaviors manually until the scripts exist:

- the template installs successfully
- `dotnet new list` shows the expected template metadata
- `dotnet new <shortName>` succeeds
- generated output restores and builds when applicable
- symbols replace correctly in file names and file contents

### 4. Update Documentation

Update release-facing documentation in the same pull request:

- `CHANGELOG.md`
- `docs/template-catalog.md`
- affected template `README.md` files
- repository-level docs if the workflow or architecture changed

### 5. Choose the Version Number

Choose the next version based on the semantic versioning rules above.

Examples:

- `0.1.0` -> first public preview with one or more usable templates
- `0.2.0` -> adds another template or a significant non-breaking feature
- `0.2.1` -> fixes symbol replacement or packaging defects
- `1.0.0` -> first stable release with a reliable install and validation flow

### 6. Prepare the Changelog

Add a new entry to [CHANGELOG.md](../CHANGELOG.md) for the version being released.

Recommended structure:

```markdown
## 1.2.0 - 2026-07-24

### Added
- Added the `eaton-webapi` project template

### Changed
- Improved symbol naming consistency in `eaton-class`

### Fixed
- Fixed file rename behavior for generated class names
```

### Changelog Rules

- Put newest releases first
- Use the release date in `YYYY-MM-DD` format
- Group changes into `Added`, `Changed`, `Fixed`, and `Removed` when useful
- Write for humans, not just for maintainers

### 7. Update the Template Catalog

For every newly released template or meaningful template revision, update
[docs/template-catalog.md](template-catalog.md).

Use [docs/template-catalog.md](template-catalog.md) as the canonical source for catalog columns,
status values, and maintenance rules.

### 8. Create the Release Commit

Create a dedicated commit for release metadata and packaging changes when
practical.

Recommended commit message examples:

- `Release 0.2.0`
- `Prepare release 1.0.0`

This makes it easier to trace tags back to the exact release state.

### 9. Package the Templates

Create the NuGet package for the repository.

Expected future command:

```powershell
.\automation\scripts\pack-templates.ps1
```

Expected output:

```text
artifacts/nuget_packages/Eaton.AustinKaylor.Templates.<version>.nupkg
```

Before publishing, verify:

- the package file exists
- the version number is correct
- the package contains the intended templates only
- template metadata matches the docs and changelog

### 10. Publish the Package

Publish the package to the target feed.

Expected future command:

```powershell
.\automation\scripts\publish-templates.ps1
```

After publishing, verify:

- the package is visible on the feed
- the published version matches the release commit
- `dotnet new install Eaton.AustinKaylor.Templates` succeeds
- `dotnet new list` shows the released templates

### 11. Tag the Release

Create a git tag that matches the package version.

Pattern:

```text
v<version>
```

Examples:

- `v0.2.0`
- `v1.0.0`
- `v1.2.0-beta.1`

Use annotated tags when possible so the release can carry metadata and notes.

### 12. Post-Release Verification

After publishing, verify the user experience end to end:

- install from a clean environment
- list installed templates
- generate at least one item template
- generate at least one project template
- restore and build generated output

Use `local_testing/` or a disposable directory for this final smoke test.

## Manual Commands

```powershell
# 1. Validate template behavior
.\automation\scripts\install-local.ps1
.\automation\scripts\validate-templates.ps1

# 2. Package the template pack
.\automation\scripts\pack-templates.ps1 -Version 1.0.0

# 3. Publish the package
.\automation\scripts\publish-templates.ps1 -Version 1.0.0 -ApiKey $env:NUGET_API_KEY
```

## Pull Request Expectations for Release-Ready Changes

A pull request that introduces releasable template changes should normally
include:

- template source changes
- metadata changes in `template.json`
- any required updates to `dotnetcli.host.json`
- template-specific README updates
- [docs/template-catalog.md](template-catalog.md) updates if a template is added or promoted
- [CHANGELOG.md](../CHANGELOG.md) entry if the change is intended for the next release

## CI/CD Expectations

As automation is added, the CI/CD workflow should enforce these stages:

### Validation Stage

- Verify JSON syntax and schema compliance
- Install templates locally in a clean environment
- Generate sample outputs for changed templates
- Restore and build generated projects
- Save logs to [artifacts/logs/](../artifacts/logs/)

### Packaging Stage

- Build the `.nupkg`
- Stamp the correct version
- Publish build artifacts for review

### Publishing Stage

- Publish only from protected branches or approved tags
- Require a successful validation and packaging stage first
- Record release metadata for auditing

## Rollback Guidance

If a release is found to be broken after publishing:

1. Stop promoting the broken version
2. Document the issue internally and in the next changelog entry
3. Publish a corrected patch release as soon as possible
4. If the feed allows unlisting, unlist the broken package instead of deleting
   history
5. Tag the corrective release normally

Avoid reusing version numbers.

## Common Release Pitfalls

### Missing Catalog or Changelog Updates

Symptoms:

- users cannot tell when a template was introduced
- docs drift from what was actually published

Prevention:

- always update [CHANGELOG.md](../CHANGELOG.md) and [docs/template-catalog.md](template-catalog.md) in the same PR as
  the releasable change

### Publishing Without Clean Validation

Symptoms:

- package installs, but generated content fails to build
- symbol replacement is broken in generated files

Prevention:

- require a clean validation run before packaging
- smoke test generated output from a clean directory

### Accidental Breaking Changes in Patch Releases

Symptoms:

- users upgrading a patch release see renamed symbols or different template UX

Prevention:

- review version impact explicitly before publishing
- treat CLI-facing changes as potentially breaking

### Stale Files in Template Source

Symptoms:

- template package contains `bin/` or `obj/`
- generated content includes unwanted local artifacts

Prevention:

- clean template folders before packaging
- validate package contents before publish

## Release Checklist

- [ ] Scope for the release is defined
- [ ] Changed templates were tested locally
- [ ] Generated output restores and builds where applicable
- [ ] [CHANGELOG.md](../CHANGELOG.md) is updated
- [ ] [docs/template-catalog.md](template-catalog.md) is updated
- [ ] Version number is chosen and reviewed
- [ ] Package contents were verified
- [ ] Package was published successfully
- [ ] Git tag was created
- [ ] Post-release install test passed

## Future Improvements

As the repository matures, add the following:

- a shared version file such as `automation/version.json`
- automated packing and publishing scripts in `automation/scripts/`
- CI validation on pull requests
- release pipelines triggered by git tags
- package content verification before publish
- automated smoke tests from clean environments

## Related Documents

- [docs/architecture.md](architecture.md)
- [docs/authoring-guide.md](authoring-guide.md)
- [docs/naming-conventions.md](naming-conventions.md)
- [docs/template-catalog.md](template-catalog.md)
- [CHANGELOG.md](../CHANGELOG.md)

