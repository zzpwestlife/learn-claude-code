---
name: brainstorming
description: "You MUST use this before any creative work. Explores user intent, requirements and design before implementation."
---

# Brainstorming

**Core Principle**: Ideas -> Design -> Approval -> Plan.
**HARD GATE**: NO implementation until design is approved.

## Process
1. **Explore & Research**: 
   - Check files, docs, context.
   - **MANDATORY**: Create `docs/research/YYYY-MM-DD-<topic>.md` analyzing existing patterns, dependencies, and constraints.
   - Ensure you understand the "intricacies" before designing.
2. **Structured Interview (Iterative)**:
   - Use `AskUserQuestion` to conduct a comprehensive interview.
   - Focus on: **Goal** (What), **Context** (Why), **Constraints** (Limits), **Success Criteria** (Done).
   - **LOOP**: If answers are vague or raise new questions, CONTINUE asking.
   - Do NOT proceed until you are confident you can design the solution without guessing.
3. **Constitution Check**: Verify against `constitution.md` (Simplicity, Security).
4. **Propose**: 2-3 approaches with trade-offs.
   - **MANDATORY TUI**: Use `AskUserQuestion` to select approach.
5. **Present Design**: Scale to complexity.
   - **MANDATORY TUI**: `AskUserQuestion` to approve/revise.
6. **Document**: Save to `docs/design/YYYY-MM-DD-<topic>.md`.
7. **Transition (MANDATORY TUI)**: 
   - Ask the user if they are ready to proceed to planning.
   - Use `AskUserQuestion` to offer:
     - **Create Plan**: Invoke `writing-plans` skill.
     - **Review Design**: Wait for user feedback on the design file.
     - **Refine**: Continue brainstorming.

## Key Rules
- **Interview First**: Always clarify requirements BEFORE proposing solutions.
- **Multiple Choice**: Prefer over open-ended.
- **YAGNI**: Remove unnecessary features.
- **Next Step**: ALWAYS `writing-plans`. Never direct implementation.

> For detailed workflow diagrams, see `.claude/docs/references/skills/brainstorming_full.md`
