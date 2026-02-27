---
name: using-git-worktrees
description: Use when starting feature work that needs isolation from current workspace or before executing implementation plans
---

# Using Git Worktrees

**Core Principle**: Systematic directory selection + safety verification = reliable isolation.

## Priority Order
1. **Existing**: `.worktrees` (hidden, preferred) > `worktrees`.
2. **Config**: Check `CLAUDE.md`.
3. **Ask**: Project-local vs Global (`~/.config/superpowers/worktrees/`).

## Safety Verification
**MUST verify directory is ignored before creating worktree:**
```bash
git check-ignore -q .worktrees || echo "ADD TO .gitignore FIRST"
```
If not ignored: Add to `.gitignore`, commit, then proceed.

## Creation Steps
1. **Determine Path**: Based on priority.
2. **Create**: `git worktree add <path> -b <branch>`.
3. **Setup**: Auto-detect (`npm install`, `cargo build`, etc.).
4. **Baseline**: Run tests (`npm test`). **MUST pass**.

> For detailed decision logic and scripts, see `.claude/docs/references/skills/git_worktrees_full.md`
