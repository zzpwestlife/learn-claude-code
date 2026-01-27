---
description: Generate a commit message based on staged changes
allowed-tools:
  - Bash(git diff --staged)
  - Bash(git branch --show-current)
---

!git branch --show-current
!git diff --staged

You are an expert developer. Please generate a concise and descriptive commit message following the Conventional Commits specification based on the git diff output above.

Structure:
<type>(<scope>): <subject>

<body>

<footer>

Rules:
1. Type must be one of: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert.
2. Subject must be imperative, lower case, no dot at the end.
3. If the diff is empty, tell the user to stage changes first.
