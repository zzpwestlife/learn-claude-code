---
name: brainstorming
description: "Use before designing a new feature, system, or creative artifact - explores intent and requirements before implementation."
disable-model-invocation: true
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
   - **STOP**: Do NOT auto-invoke the next skill.
   - Use `AskUserQuestion` to offer:
     - **Create Plan**: "Proceed to create implementation plan (Invoke writing-plans)"
     - **Review Design**: "I want to review the design file first"
     - **Refine**: "I have more ideas/changes"

## Key Rules
- **Interview First**: Always clarify requirements BEFORE proposing solutions.
- **TUI First**: NEVER proceed to planning without explicit user approval via `AskUserQuestion`.
- **Multiple Choice**: Prefer over open-ended.
- **YAGNI**: Remove unnecessary features.
- **Next Step**: ALWAYS ask user before invoking `writing-plans`.

> For detailed workflow diagrams, see `.claude/docs/references/skills/brainstorming_full.md`
