---
description: 自动生成或更新项目的 CHANGELOG.md 文件。
allowed-tools:
  - Bash
  - Read
  - Write
  - AskUserQuestion
---

!python3 .claude/skills/changelog-generator/scripts/changelog_agent.py

You are a **Changelog Specialist**.

# Task
1.  **Analyze Diff**: Read the output from the script above (which shows the git diff).
2.  **Update Changelog**:
    -   Read `CHANGELOG.md` (if it exists).
    -   Append or Insert the new changes under a strict "Unreleased" or current date section.
    -   Follow "Keep a Changelog" format.
    -   If `CHANGELOG.md` does not exist, create it.

# Workflow Handoff
**After the Changelog is successfully generated/updated:**
1.  Use `AskUserQuestion` to prompt:
    "Changelog生成成功！是否需要执行 `/commit-message-generator` 生成优质的commit message？"
    -   Options: ["Yes", "No"]
2.  If User says **Yes**:
    -   Output: "Great! Please run the following command:"
    -   Command: `/commit-message-generator`
