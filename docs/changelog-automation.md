## Automated CHANGELOG.md Updates

This document explains how the automated changelog update system works.

## Overview

When a pull request is merged to the `main` branch, the GitHub Actions workflow automatically extracts changelog entries from the PR body and appends them to the `CHANGELOG.md` file under the "Unreleased" section.

## How It Works

### Step 1: Contributor Fills in PR Template

When creating a PR, contributors use the PR template (`.github/pull_request_template.md`) which includes structured sections for changelog entries:

```markdown
### <!-- CHANGELOG_START -->Added<!-- CHANGELOG_END -->
- New feature description

### <!-- CHANGELOG_START -->Changed<!-- CHANGELOG_END -->
- Change description

### <!-- CHANGELOG_START -->Fixed<!-- CHANGELOG_END -->
- Bug fix description

### <!-- CHANGELOG_START -->Removed<!-- CHANGELOG_END -->
- Removed item description
```

Contributors fill in only the sections that apply to their changes. Empty sections can be left as-is or removed entirely.

### Step 2: PR is Reviewed and Merged

The reviewer verifies the PR and changelog entries along with the code changes.

### Step 3: Workflow Triggers on Merge

When the PR is merged, the `update-changelog` job in `.github/workflows/basic_ci.yml` automatically:

1. Checks out the repository with full history
2. Extracts changelog sections from the PR body using markers:
   - `<!-- CHANGELOG_START -->Added<!-- CHANGELOG_END -->`
   - `<!-- CHANGELOG_START -->Changed<!-- CHANGELOG_END -->`
   - `<!-- CHANGELOG_START -->Fixed<!-- CHANGELOG_END -->`
   - `<!-- CHANGELOG_START -->Removed<!-- CHANGELOG_END -->`

3. Runs the PowerShell script `automation/scripts/update-changelog-from-pr.ps1` which:
   - Parses bullet points from each section
   - Filters out empty entries and instructions
   - Appends entries to the "Unreleased" section of `CHANGELOG.md`

4. Commits the changes with message: `docs: update CHANGELOG.md from PR #123`
5. Pushes the commit back to main

### Step 4: Release Process

When you're ready to release, the release maintainer:

1. Identifies the version number (using semantic versioning)
2. Moves the "Unreleased" section entries to a new version entry (e.g., `## 1.2.0 - 2026-07-24`)
3. Continues with the standard release process per `docs/release-process.md`

## Files Modified/Created

| File | Purpose |
|------|---------|
| `.github/pull_request_template.md` | PR template with changelog sections |
| `.github/workflows/basic_ci.yml` | Updated workflow with `update-changelog` job |
| `automation/scripts/update-changelog-from-pr.ps1` | PowerShell script for changelog extraction |

## PR Template Usage

### For a New Feature

```markdown
### <!-- CHANGELOG_START -->Added<!-- CHANGELOG_END -->
- Added the `eaton-webapi` project template
- Added support for async/await patterns in code generation
```

### For a Bug Fix

```markdown
### <!-- CHANGELOG_START -->Fixed<!-- CHANGELOG_END -->
- Fixed file rename behavior for generated class names
- Fixed symbol replacement in template variables
```

### For Multiple Changes

```markdown
### <!-- CHANGELOG_START -->Added<!-- CHANGELOG_END -->
- Added new template

### <!-- CHANGELOG_START -->Changed<!-- CHANGELOG_END -->
- Improved documentation

### <!-- CHANGELOG_START -->Fixed<!-- CHANGELOG_END -->
- Fixed validation logic
```

## Workflow Behavior

### When Changelog Entries Are Found

```
✅ Extracted changelog entries:
  [Added]
    - New template description
  [Fixed]
    - Bug fix description
✅ Successfully updated CHANGELOG.md
```

The workflow commits the changes and pushes to main.

### When No Changelog Entries Are Found

```
ℹ️  No changelog entries found in PR body. Skipping changelog update.
```

The workflow exits gracefully with no changes. This allows for PRs that don't require changelog updates (e.g., CI/CD improvements, internal refactoring).

### When "Unreleased" Section Is Missing

```
⚠️  Warning: 'Unreleased' section not found in CHANGELOG.md. Skipping update.
```

The workflow logs a warning. Ensure `CHANGELOG.md` contains the `## Unreleased` section.

## Permissions

The `update-changelog` job requires:

- `contents: write` — to commit and push changes
- `pull-requests: read` — to read PR body content

These permissions are requested only for this job and follow the principle of least privilege.

## Troubleshooting

### Changelog Not Updating

1. **Check PR body format**: Ensure the PR body contains the exact markers:
   - `<!-- CHANGELOG_START -->SectionName<!-- CHANGELOG_END -->`
   - Replace `SectionName` with `Added`, `Changed`, `Fixed`, or `Removed`

2. **Verify entries are bullet points**: Each entry must start with `- ` (dash and space)
   ```markdown
   ❌ Wrong: Added text without dash
   ✅ Correct: - Added this feature
   ```

3. **Check CHANGELOG.md structure**: Ensure it contains `## Unreleased` section
   ```markdown
   ## Unreleased

   Use this section to collect release notes before the next package is published.
   ```

4. **Review workflow logs**: Check the GitHub Actions logs for the `update-changelog` job for detailed error messages

### Duplicate Entries

If you see duplicate entries in CHANGELOG.md:

1. Manually clean up the file
2. Ensure the PR template markers are used correctly
3. The script should prevent duplicates in future merges

## Integration with Release Process

This automation works seamlessly with the existing release process:

1. **During Development**: Changelog entries accumulate in the "Unreleased" section
2. **Before Release**: Release maintainer reviews accumulated entries in "Unreleased"
3. **During Release**: Move entries to a new version section (e.g., `## 1.0.0 - 2026-07-24`)
4. **After Release**: Continue with packaging and publishing as documented in `docs/release-process.md`

See [release-process.md](release-process.md) for the complete release workflow.

