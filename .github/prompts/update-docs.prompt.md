---
agent: 'default chat'
---
Analyze all Markdown files under `docs/` and synchronize each document with the current repository state based on changes made since that document was last updated.

Requirements:
- Inspect every `docs/*.md` file.
- Compare document content with current code, scripts, templates, and workflows in the repository.
- Identify outdated, missing, inconsistent, or incorrect documentation.
- Update each document in place so it accurately reflects current behavior, file paths, commands, naming, and release workflow.
- Preserve each document's intent, structure, and tone while improving clarity and correctness.
- Keep changes concise, avoid speculative content, and avoid introducing unverified claims.

Constraints:
- Do not modify files outside `docs/` unless explicitly required to fix broken links to existing files.
- Use existing repository conventions for Markdown formatting.
- Prefer minimal, high-confidence edits over broad rewrites.
- If a fact cannot be verified from repository contents, call it out as an open question instead of guessing.

Success criteria:
- All `docs/*.md` files are reviewed and synchronized with current repository state.
- Commands and paths in docs are valid for the current repo structure.
- Any outdated guidance is corrected or removed.
- A concise change summary is produced listing updated files and key fixes.
- Any unresolved ambiguities are listed clearly as follow-up questions.
