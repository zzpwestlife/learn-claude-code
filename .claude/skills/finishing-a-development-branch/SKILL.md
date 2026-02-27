---
name: finishing-a-development-branch
description: Use when implementation is complete, all tests pass, and you need to decide how to integrate the work
---

# Finishing a Development Branch

**Core Principle**: Verify tests → Present options → Execute choice → Clean up.

## Process
1. **Verify Tests**: Run full suite. **MUST PASS**.
   - If fail: Stop. Report failures. Do not proceed.

2. **Determine Base**: Identify parent branch (main/master).

3. **Present Options (MANDATORY TUI)**:
   - Use `AskUserQuestion` with these options:
     1. **Merge Locally** (cleanup branch + worktree)
     2. **Create PR** (push + keep worktree)
     3. **Keep As-Is** (do nothing)
     4. **Discard** (force delete - require confirmation)

4. **Execute & Cleanup**:
   - **Merge**: `git merge` -> Verify -> Delete branch -> Remove worktree.
   - **PR**: `gh pr create` -> Keep worktree.
   - **Discard**: Confirm -> `git branch -D` -> Remove worktree.

> For detailed scripts and safety checks, see `.claude/docs/references/skills/finishing_branch_full.md`
