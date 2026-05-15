---
description: 智能生成符合 Conventional Commits 规范的 commit message，支持双语解析与多模板输出。
argument-hint: [context_focus]
model: haiku
allowed-tools: [Bash, AskUserQuestion, RunCommand]
---

!git status --porcelain
!git diff --staged --name-only
!git diff --staged

# Commit Message Generator

Role: Senior Code Auditor.
Standard: Conventional Commits `<type>(<scope>): <subject>`.

1. If no staged files, ask the user to `git add`.
2. If the index is clean, exit.
3. Infer `type`, `scope`, and breaking changes from staged diff.
4. Output:
   - 中文变更摘要
   - 标准版 commit message
   - 详细版 commit message
5. End with TUI options:
   - `Done`
   - `Regenerate Message`

> For detailed type reference and examples, see `.claude/docs/references/commands/commit_msg_full.md`
