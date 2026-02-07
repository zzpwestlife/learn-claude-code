---
description: 根据暂存区变更生成提交信息
allowed-tools:
  - Bash(git diff --staged)
  - Bash(git branch --show-current)
---

!git branch --show-current
!git diff --staged

你是一名资深开发者。请根据上方 git diff 输出，按照 Conventional Commits 规范生成简洁且描述明确的提交信息。

结构：
<type>(<scope>): <subject>

<body>

<footer>

规则：
1. Type 必须为以下之一：feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert。
2. Subject 必须使用祈使语气、小写结尾且不加句号。
3. 若 diff 为空，提示用户先暂存变更。


**Notification**:
When the task is complete, you MUST notify the user by running:
`/Applications/ServBay/script/alias/node /Users/admin/claude-code-notification/src/index.js --type success --title 'Command commit' --message 'Execution finished.'`
(Ensure CLAUDE_WEBHOOK_URL is set in your environment).
