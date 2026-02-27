---
name: using-superpowers
description: Use when you need to access or modify user-defined superpowers (global config)
---

# Using Superpowers

**Core Principle**: Read Global Config -> Apply Local Overrides -> Execute.

## Locations
- **Global**: `~/.config/superpowers/` (Source of Truth)
- **Local**: `.claude/superpowers.lock.json` (Project Lockfile)

## Process
1. **Sync**: Run `python3 .claude/lib/python/sync-superpowers.py`.
2. **Read**: Check `superpowers.lock.json` for available tools.
3. **Execute**: Use tools as defined in `AGENTS.md`.

> For detailed configuration schema, see `.claude/docs/references/skills/using_superpowers_full.md`
