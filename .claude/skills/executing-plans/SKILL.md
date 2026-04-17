---
name: executing-plans
description: Execute implementation plans with review checkpoints.
version: "2.0.0"
---

# Executing Plans

Load plan, execute tasks, review, finish branch. Supports sequential or subagent-parallel modes.

## Mode Selection

| Condition | Mode |
|-----------|------|
| Tasks independent + subagents available | **Subagent mode** (fresh agent per task) |
| Tasks tightly coupled OR no subagents | **Sequential mode** (execute in current session) |

## The Process

### Step 1: Load and Review Plan

1. Read plan file.
2. Review critically — raise concerns before starting.
3. Create task list and proceed.

### Step 2: Execute Tasks

#### Sequential Mode

For each task:
1. Mark as `in_progress`.
2. Follow each step exactly.
3. Run verifications as specified.
4. Mark as `completed`.
5. After each chunk: run `git diff`, present TUI options (Continue / Review / Pause).

#### Subagent Mode

For each task:
1. Dispatch implementer subagent with full task text + context (see `assets/prompts/implementer-prompt.md`).
2. If implementer asks questions — answer before proceeding.
3. Dispatch spec reviewer (`assets/prompts/spec-reviewer-prompt.md`) — must pass before quality review.
4. Dispatch code quality reviewer (`assets/prompts/code-quality-reviewer-prompt.md`).
5. If issues found: implementer fixes → re-review until approved.
6. Mark task complete.

**Implementer statuses:** DONE (proceed), DONE_WITH_CONCERNS (assess), NEEDS_CONTEXT (provide & re-dispatch), BLOCKED (escalate).

**Model selection:** Cheap model for 1-2 file mechanical tasks, standard for integration, capable for architecture/review.

### Step 3: Finish Branch

After all tasks complete:

1. **Verify tests pass** (`npm test` / `go test ./...` / `pytest`). Stop if failing.
2. **Determine base branch** (`git merge-base HEAD main`).
3. **Present 4 options:**
   - Merge back to base branch locally
   - Push and create a Pull Request
   - Keep the branch as-is
   - Discard this work (requires typed "discard" confirmation)
4. **Clean up worktree** for merge/discard options; keep for PR/as-is.

## When to Stop

- Hit a blocker (missing dependency, test fails, instruction unclear).
- Plan has critical gaps.
- Verification fails repeatedly.

**Ask for clarification rather than guessing.**

## Red Flags

**Never:**
- Start on main/master without explicit consent.
- Skip reviews (spec compliance OR code quality).
- Dispatch parallel implementation subagents (conflicts).
- Proceed with unfixed issues.
- Force-push without explicit request.

**Always:**
- Follow plan steps exactly.
- Verify tests before offering finish options.
- Get typed confirmation for discard.
