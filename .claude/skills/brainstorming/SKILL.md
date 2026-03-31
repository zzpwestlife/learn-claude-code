---
name: brainstorming
description: "Use before designing a new feature, system, or creative artifact - explores intent and requirements before implementation."
---

# Brainstorming Ideas Into Designs

Help turn ideas into fully formed designs and specs through natural collaborative dialogue.

Start by understanding the current project context, then ask questions one at a time to refine the idea. Once you understand what you're building, present the design and get user approval.

<HARD-GATE>
**Core Principle**: Ideas -> Design -> Approval -> Plan.
Do NOT invoke any implementation skill, write any code, scaffold any project, or take any implementation action until you have presented a design and the user has approved it. This applies to EVERY project regardless of perceived simplicity.
</HARD-GATE>

## Process & Checklist

You MUST create a task for each of these items and complete them in order:

1. **Explore project context & Research** — Check files, docs, context. **MANDATORY**: Create `docs/research/YYYY-MM-DD-<topic>.md` analyzing existing patterns, dependencies, and constraints. Ensure you understand the "intricacies" before designing.
2. **Offer visual companion** (if topic will involve visual questions) — this is its own message, not combined with a clarifying question.
3. **The "Grill-Me" Interview (Stress-Test & Deep Dive)**:
   - Break the user's plan/idea into a **decision tree**. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one.
   - **Relentless Questioning**: Interview the user relentlessly about every aspect of this plan until reaching a shared understanding. Do NOT accept vague answers.
   - **Autonomous Exploration**: If a question can be answered by exploring the codebase, **explore the codebase instead** (use `SearchCodebase`/`Grep`) rather than asking the user.
   - Focus on: **Edge Cases**, **Dependencies**, **Failure Modes**, and **Success Criteria**.
   - **Devil's Advocate (魔鬼代言人)**: Explicitly challenge the user's core idea. Find every wrong assumption, every ignored risk, and every reason it might fail. Do NOT hold back.
   - **LOOP**: Do NOT proceed until you are confident every branch has been resolved without guessing.
4. **Constitution Check**: Verify against `constitution.md` (Simplicity, Security).
5. **Pre-mortem (前期验尸)**: Before proposing approaches, run a pre-mortem: "Assume this feature fails completely in 6 months. Here are the 3 most likely specific reasons why." Ensure the design mitigates these.
6. **Propose 2-3 approaches** — with trade-offs. **MANDATORY TUI**: Use `AskUserQuestion` to select approach.
7. **Present design** — in sections scaled to complexity. **MANDATORY TUI**: Use `AskUserQuestion` to approve/revise.
8. **Write design doc** — save to `docs/design/YYYY-MM-DD-<topic>-design.md` and commit.
9. **Spec self-review** — quick inline check for placeholders, contradictions, ambiguity, scope.
10. **Transition (CRITICAL TOOL CALL REQUIRED)** — Use `AskUserQuestion` to ask user what's next before proceeding to planning.

## The Process Details

**Understanding the idea:**
- Check out the current project state first (files, docs, recent commits)
- Before asking detailed questions, assess scope. Decompose if needed.
- Prefer multiple choice questions when possible.
- Focus on: **Edge Cases**, **Dependencies**, **Failure Modes**, and **Success Criteria**. Do NOT proceed until you are confident.

**Exploring approaches:**
- Propose 2-3 different approaches with trade-offs.
- Present options conversationally with your recommendation and reasoning.

**Presenting the design:**
- Scale each section to its complexity.
- Ask after each section whether it looks right so far.

**Design for isolation and clarity:**
- Break the system into smaller units that each have one clear purpose.
- Files that change together should live together. Split by responsibility.

## After the Design

**Documentation:**
- Write the validated design (spec) to `docs/design/YYYY-MM-DD-<topic>-design.md`.
- Commit the design document to git.

**Spec Self-Review:**
Fix placeholders, internal consistency, scope check, ambiguity check inline.

**Transition Gate (CRITICAL TOOL CALL REQUIRED):**
After saving the document and self-review, you are **FORBIDDEN** from simply saying "complete" or "done".
You **MUST ACTUALLY EXECUTE** the `AskUserQuestion` tool to present the next steps.
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

## Visual Companion
A browser-based companion for showing mockups, diagrams, and visual options during brainstorming.
**Offering the companion:** If upcoming questions involve visual content, offer it once for consent as its own message.
- **Use the browser** for content that IS visual — mockups, wireframes, etc.
- **Use the terminal** for content that is text — requirements questions, conceptual choices, etc.
