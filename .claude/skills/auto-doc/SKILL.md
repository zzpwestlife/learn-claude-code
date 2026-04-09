---
name: auto-doc
description: Use after code changes to sync docs - updates inline comments, README, and reference docs in one pass.
disable-model-invocation: true
version: "1.0.0"
---

# Auto-Doc Skill

**Rule**: Code change = Doc change.

## 3-Layer Structure
1. **Level 3 (File Header)**: `@module`, `@desc`, `@input`, `@output`.
   - Update on logic/IO change.
2. **Level 2 (CLAUDE.md)**: Directory Manifest & Context Rules.
   - Update on file add/remove/rename.
3. **Level 1 (ARCHITECTURE.md)**: System Design.
   - Update on major module change.

## Trigger Table
| Event | Header | CLAUDE.md | ARCHITECTURE.md |
| :--- | :---: | :---: | :---: |
| Logic | ✅ | ❌ | ❌ |
| I/O | ✅ | ✅ | ❌ |
| Add File | ✅ | ✅ | ❌ |
| Remove File | N/A | ✅ | ❌ |
| Module | N/A | ✅ | ✅ |

**Output format**: When directing doc updates, always name the level explicitly: "**Level 3 (File Header)**", "**Level 2 (CLAUDE.md)**", or "**Level 1 (ARCHITECTURE.md)**".

> For detailed template and examples, see `.claude/docs/references/skills/auto_doc_full.md`
