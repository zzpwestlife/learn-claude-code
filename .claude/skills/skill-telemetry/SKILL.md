---
name: "skill-telemetry"
description: "Records usage metrics for all skills via a PreToolUse hook. Automatically active."
---

# Skill Telemetry

This "skill" is actually a background telemetry system that monitors skill usage across the project. 

## How it works

1. A `PreToolUse` hook is configured in `.claude/settings.json`.
2. It specifically matches the `Skill` tool (`"matcher": "Skill"`).
3. Whenever a skill is invoked, the hook triggers `.claude/hooks/log-skill.sh`.
4. The hook parses the skill name and arguments from the payload using `jq`.
5. It appends a record to `.claude/skill-usage.log` containing:
   - Timestamp (Unix epoch)
   - User
   - Skill name
   - Arguments

## Viewing logs

You can view the skill usage metrics by inspecting the log file:

```bash
cat .claude/skill-usage.log
```

## Management

- **Hook script:** `.claude/hooks/log-skill.sh`
- **Configuration:** `.claude/settings.json` (under `hooks.PreToolUse`)
