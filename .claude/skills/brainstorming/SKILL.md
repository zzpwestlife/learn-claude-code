---
name: brainstorming
description: "You MUST use this before any creative work. Explores user intent, requirements and design before implementation."
---

# Brainstorming

**Core Principle**: Ideas -> Design -> Approval -> Plan.
**HARD GATE**: NO implementation until design is approved.

## Process
1. **Explore**: Check files, docs, context.
2. **Clarify**: Ask ONE question at a time.
3. **Constitution Check**: Verify against `constitution.md` (Simplicity, Security).
4. **Propose**: 2-3 approaches with trade-offs.
   - **MANDATORY TUI**: Use `AskUserQuestion` to select approach.
5. **Present Design**: Scale to complexity.
   - **MANDATORY TUI**: `AskUserQuestion` to approve/revise.
6. **Document**: Save to `docs/design/YYYY-MM-DD-<topic>.md`.
7. **Transition**: Invoke `writing-plans` skill.

## Key Rules
- **One Question**: Don't overwhelm.
- **Multiple Choice**: Prefer over open-ended.
- **YAGNI**: Remove unnecessary features.
- **Next Step**: ALWAYS `writing-plans`. Never direct implementation.

> For detailed workflow diagrams, see `.claude/docs/references/skills/brainstorming_full.md`
