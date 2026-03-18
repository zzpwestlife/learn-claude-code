# HANDOFF — learn-claude-code

## Current State (2026-03-18)

### Last Work
Health audit of the `.claude/` configuration system. Applied 15 fixes across hooks, settings, skills, and rules.

### What Was Changed This Session
| File | Change |
|------|--------|
| `.claude/settings.local.json` | Fixed hook path, removed dead MCP allowedTools, removed `Bash(done)` |
| `.claude/hooks/go/format-go-code.sh` | Silenced success echo |
| `.gitignore` | Added `settings.local.json` |
| `.claude/skills/executing-plans/SKILL.md` | Replaced hardcoded path with `$CLAUDE_PROJECT_DIR` |
| `.claude/rules/CORE_RULES.md` | Fixed `RunCommand` → `Bash` |
| `.claude/AGENTS.md` | Added done-conditions + session-start lessons reminder |
| 6 skill frontmatters | Fixed descriptions + added `disable-model-invocation: true` |
| `~/.claude/.../memory/MEMORY.md` | Created with project architecture |

### Open Items
- [ ] Python formatting hook (tool preference: ruff / black / none?)
- [ ] Three-layer enforcement for "Universal Handoff" and "No `git add .`" rules
- [ ] `~/.claude/skills/` placement violates CORE_RULES §6 — needs explicit exception or migration
- [ ] 18 skills missing `version` field in frontmatter
- [ ] 3 nested `CLAUDE.md` files to review (`scripts/`, `templates/go/`, `claude_plugins/gopls/`)
- [ ] No global `~/.claude/CLAUDE.md` for cross-project preferences

### Architecture Reminder
This project IS the Claude Code config system — the `.claude/` directory is the product, not supporting infrastructure. Skills are the primary extension mechanism since the paradigm shift (command-driven → intent-driven, commit 48227b2).
