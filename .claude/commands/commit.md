---
description: Generate commit message based on staged changes
allowed-tools:
  - Bash(git diff --staged)
  - Bash(git branch --show-current)
---

!git branch --show-current
!git diff --staged

You are a senior developer. Please generate a concise and descriptive commit message based on the git diff output above, following Conventional Commits specification.

Structure:
<type>(<scope>): <subject>

<body>

<footer>

Rules:
1. Type must be one of: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert.
2. Subject must use imperative mood, lowercase ending, and no period.
3. If diff is empty, prompt the user to stage changes first.
