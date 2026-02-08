# Claude Code Core Configuration Directory

**Purpose**: Centralized configuration directory for Claude Code agents, commands, hooks, and skills.

## Structure

```
.claude/
├── agents/           # Agent role definitions (7)
│   ├── architect.md
│   ├── code-builder.md
│   ├── code-reviewer.md
│   ├── code-scribe.md
│   ├── security-auditor.md
│   ├── test-validator.md
│   └── changelog-generator.md
├── commands/         # Custom Slash commands
│   ├── commit.md
│   └── review-code.md
├── hooks/
│   └── go/
├── skills/
│   ├── notifier/
│   └── changelog-generator/
├── settings.json
└── changelog_config.json
```

## WHERE TO LOOK

| Task | Path |
|------|------|
| Add new Agent | `.claude/agents/*.md` |
| Add new Command | `.claude/commands/*.md` |
| Add Hook | `.claude/hooks/` |
| Configure permissions | `.claude/settings.json` |
| Add Skill | `.claude/skills/` |

## ANTI-PATTERNS

- ❌ Prohibit hardcoding local paths in Agents
- ❌ Prohibit granting unnecessary Write/Edit permissions
- ❌ Prohibit skipping Hook error checks
- ❌ Prohibit creating Agents with overlapping functionality (merge first)
