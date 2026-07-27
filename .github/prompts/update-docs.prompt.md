---
agent: 'default chat'
---
Analyze all Markdown files under `docs/` and synchronize each document with the current repository state based on changes made since that document was last updated.

## Requirements
- Inspect every `docs/*.md` file.
- Compare document content with current code, scripts, templates, and workflows in the repository.
- Identify outdated, missing, inconsistent, or incorrect documentation.
- Update each document in place so it accurately reflects current behavior, file paths, commands, naming, and release workflow.
- Preserve each document's intent, structure, and tone while improving clarity and correctness.
- Keep changes concise, avoid speculative content, and avoid introducing unverified claims.

## Constraints
- Do not modify files outside `docs/` unless explicitly required to fix broken links to existing files.
- Use existing repository conventions for Markdown formatting.
- Prefer minimal, high-confidence edits over broad rewrites.
- If a fact cannot be verified from repository contents, call it out as an open question instead of guessing.
- Use the documentation map below to ensure all relevant documents are reviewed and updated.
- Use the documentation map below to ensure each document is internally consistent with it's intended purpose and with other documents in the repository.

### Documentation Map

Use these documents as the primary entry points for working in the repository:

| Document                     | Purpose                                                         |
|------------------------------|-----------------------------------------------------------------|
| `docs/architecture.md`       | Repository structure, system design, and document ownership     |
| `docs/authoring-guide.md`    | How to create, configure, and test templates                    |
| `docs/naming-conventions.md` | Identity, `shortName`, folder, symbol, and package naming rules |
| `docs/release-process.md`    | Versioning, packaging, publishing, and release workflow         |
| `docs/template-catalog.md`   | Template inventory and lifecycle status tracking                |
| `tests/Item.Tests/README.md` | Test-runner setup and snapshot baseline update workflow         |

## Success criteria
- All `docs/*.md` files are reviewed and synchronized with current repository state.
- Commands and paths in docs are valid for the current repo structure.
- Any outdated guidance is corrected or removed.
- A concise change summary is produced listing updated files and key fixes.
- Any unresolved ambiguities are listed clearly as follow-up questions.
