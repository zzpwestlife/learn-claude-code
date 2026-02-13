---
description: 自动生成或更新项目的 CHANGELOG.md 文件。支持指定输出目录。
argument-hint: [output_dir]
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
1.  **Analyze Arguments**: Check if an argument is provided. If it looks like a directory path, treat it as `output_dir`.
2.  **Visual Progress**: Start output with `[✔ Optimize] → [✔ Plan] → [✔ Execute] → [✔ Review] → [➤ Changelog] → [Commit]`
3.  **Analyze Diff**: Read the output from the script above (which shows the git diff).
4.  **Update Changelog**:
    -   Determine target file:
        -   If `output_dir` is provided: `output_dir/CHANGELOG.md`
        -   Otherwise: `CHANGELOG.md` (in current root)
    -   Read the target file (if it exists).
    -   Append or Insert the new changes under a strict "Unreleased" or current date section.
    -   Follow "Keep a Changelog" format.
    -   If file does not exist, create it.

# Workflow Handoff
**After the Changelog is successfully generated/updated:**

1.  **Visual Confirmation**:
    ```text
    ────────────────────────────────────────────────────────────────────────────────
    ←  ✔ Update Changelog  ☐ Generate Commit Message  →

    Changelog 已更新至 `{target_file}`。下一步：

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
    -   **Action**: Use `RunCommand` tool to execute `/commit-message-generator {output_dir}`.
    -   **Important**: Set `requires_approval: true`. This allows the user to simply confirm (Tab/Enter) to proceed.
