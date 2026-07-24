## Changelog

This file records release notes for the template package published from this
repository.

Use it together with `docs/release-process.md` when preparing a release.

## Format

Follow these rules for every changelog entry:

- Put the newest release first
- Use the version heading format `## <version> - YYYY-MM-DD`
- Group notable changes under these headings when useful:
  - `### Added`
  - `### Changed`
  - `### Fixed`
  - `### Removed`
- Write concise notes that explain the user-facing impact

## Unreleased

Use this section to collect release notes before the next package is published.

### Added

- Initial repository documentation set created for architecture, authoring,
  naming conventions, release process, and template catalog.
- Automation scripts: `install-local.ps1`, `uninstall-local.ps1`,
  `validate-templates.ps1`, `pack-templates.ps1`, `publish-templates.ps1`,
  and the shared helpers module `shared.ps1`.

### Changed

- Root `README.md` aligned with the repository structure and canonical docs.

### Fixed

- Documentation consistency issues across paths, package naming, and CLI
  parameter examples.

## Release Template

Copy this structure when publishing a release:

```markdown
## 0.1.0 - 2026-07-24

### Added
- Added the first published template(s).

### Changed
- Updated template metadata and supporting documentation.

### Fixed
- Fixed template generation or packaging issues discovered during validation.
```

## Notes

- Keep release notes focused on user-visible behavior
- If a template is deprecated, mention the recommended replacement
- If a release contains a breaking change, call it out clearly in the entry

