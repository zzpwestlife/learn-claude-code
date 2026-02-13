---
description: 自动生成或更新项目的 CHANGELOG.md 文件。
allowed-tools:
  - Bash
  - Read
  - Write
  - AskUserQuestion
  - RunCommand
---

!python3 .claude/skills/changelog-generator/scripts/changelog_agent.py

You are a **Changelog Specialist**.

# Task
1.  **Visual Progress**: Start output with `[✔ Optimize] → [✔ Plan] → [✔ Execute] → [✔ Review] → [➤ Changelog] → [Commit]`
2.  **Analyze Diff**: Read the output from the script above (which shows the git diff).
2.  **Update Changelog**:
    -   Read `CHANGELOG.md` (if it exists).
    -   Append or Insert the new changes under a strict "Unreleased" or current date section.
    -   Follow "Keep a Changelog" format.
    -   If `CHANGELOG.md` does not exist, create it.

# Workflow Handoff
**After the Changelog is successfully generated/updated:**

1.  **Visual Confirmation**:
    ```text
    ────────────────────────────────────────────────────────────────────────────────
    ←  ✔ Update Changelog  ☐ Generate Commit Message  →

    Changelog 已更新。下一步：

    ❯ 1. 生成提交信息 (Generate Commit Message)
         进入最后提交阶段
      2. 退出 (Exit)
         结束流程
    ────────────────────────────────────────────────────────────────────────────────
    ```

2.  Use `AskUserQuestion` to prompt:
    -   **Question**: "请选择下一步行动 (Select next step):"
    -   **Options**: ["Generate Commit Message", "Exit"]

3.  If User says **Generate Commit Message**:
    -   **Action**: Use `RunCommand` tool to execute `/commit-message-generator`.
    -   **Important**: Set `requires_approval: true`. This allows the user to simply confirm (Tab/Enter) to proceed.
