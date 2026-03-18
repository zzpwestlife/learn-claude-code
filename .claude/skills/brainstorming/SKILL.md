---
name: brainstorming
description: "Use before designing a new feature, system, or creative artifact - explores intent and requirements before implementation."
---

# Brainstorming

**Core Principle**: Ideas -> Design -> Approval -> Plan.
**HARD GATE**: NO implementation until design is approved.

## Process
1. **Explore & Research**: 
   - Check files, docs, context.
   - **MANDATORY**: Create `docs/research/YYYY-MM-DD-<topic>.md` analyzing existing patterns, dependencies, and constraints.
   - Ensure you understand the "intricacies" before designing.
2. **The "Grill-Me" Interview (Stress-Test & Deep Dive)**:
   - Break the user's plan/idea into a **decision tree**. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one.
   - **Relentless Questioning**: Interview the user relentlessly about every aspect of this plan until reaching a shared understanding. Do NOT accept vague answers.
   - **Autonomous Exploration**: If a question can be answered by exploring the codebase, **explore the codebase instead** (use `SearchCodebase`/`Grep`) rather than asking the user.
   - Focus on: **Edge Cases**, **Dependencies**, **Failure Modes**, and **Success Criteria**.
   - **LOOP**: Do NOT proceed until you are confident every branch has been resolved without guessing.
3. **Constitution Check**: Verify against `constitution.md` (Simplicity, Security).
4. **Propose**: 2-3 approaches with trade-offs.
   - **MANDATORY TUI**: Use `AskUserQuestion` to select approach.
5. **Present Design**: Scale to complexity.
   - **MANDATORY TUI**: `AskUserQuestion` to approve/revise.
6. **Document**: Save to `docs/design/YYYY-MM-DD-<topic>.md`.
7. **Transition (CRITICAL TOOL CALL REQUIRED)**: 
   - After saving the document, you are **FORBIDDEN** from simply saying "complete" or "done".
   - You **MUST ACTUALLY EXECUTE** the `AskUserQuestion` tool to present the next steps. If you do not call the tool, you have failed the user.
   - Set the `question` parameter to: "Brainstorming and Design complete. What is the next step?"
   - Set the `options` parameter to exactly these three choices:
     1. `label`: "Proceed to Planning", `description`: "Invoke writing-plans skill to create BDD state tracking plan"
     2. `label`: "Review Design", `description`: "I want to review the generated design file first"
     3. `label`: "Refine", `description`: "I have more ideas/changes to add"
   - Wait for the user's selection via the tool before ending your turn.

## Key Rules
- **Interview First**: Always clarify requirements BEFORE proposing solutions.
- **TUI First**: NEVER proceed to planning without explicit user approval via `AskUserQuestion`.
- **Multiple Choice**: Prefer over open-ended.
- **YAGNI**: Remove unnecessary features.
- **Next Step**: ALWAYS ask user before invoking `writing-plans`.

> For detailed workflow diagrams, see `.claude/docs/references/skills/brainstorming_full.md`
