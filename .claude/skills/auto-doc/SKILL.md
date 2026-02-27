---
name: auto-doc
description: Ensure documentation is always synchronized with code changes through a mandatory 3-layer update process.
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
| Add/Del | ✅ | ✅ | ❌ |
| Module | N/A | ✅ | ✅ |

> For detailed template and examples, see `.claude/docs/references/skills/auto_doc_full.md`
