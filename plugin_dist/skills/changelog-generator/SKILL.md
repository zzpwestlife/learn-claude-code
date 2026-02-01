---
name: "changelog-generator"
description: "通过分析当前分支与主分支 (main/master) 之间的 Git 差异，辅助生成项目变更日志。此工具负责提取代码差异和提交变更，日志内容的分析与生成由 AI Agent 完成。"
---

# 变更日志生成器 (Changelog Generator)

本 Skill 提供了一个辅助脚本 `changelog_agent.py`，用于支持 AI Agent 完成变更日志的生成工作流。

## 工作流 (Workflow)

生成 Changelog 的过程由 AI Agent 驱动，脚本仅作为工具使用：

1.  **获取差异 (Fetch Diff)**: Agent 运行脚本获取当前代码与主分支的差异。
2.  **分析总结 (Analyze & Summarize)**: Agent 读取脚本输出的差异内容，利用 AI 能力分析代码变更的语义，生成高质量的 Changelog 内容。
3.  **更新文件 (Update File)**: Agent 将生成的内容写入 `CHANGELOG.md`。
4.  **提交变更 (Commit)**: Agent 再次运行脚本，将代码变更和 CHANGELOG 一起提交。

## 用法 (Usage)

### 1. 获取代码差异 (Get Git Diff)

获取当前分支（包括未提交的变更）与主分支 (`main` 或 `master`) 之间的所有代码差异。

- **命令**: `python3 .claude/skills/changelog-generator/scripts/changelog_agent.py`
- **输出**: 标准输出 (stdout) 显示完整的 `git diff` 内容。Agent 应读取此输出进行分析。

### 2. 提交变更 (Commit Changes)

将当前的所有变更（包括对 `CHANGELOG.md` 的修改和代码变更）提交到 Git。

- **命令**: `python3 .claude/skills/changelog-generator/scripts/changelog_agent.py --commit --message "feat: description of changes"`
- **参数**:
    - `--commit`: 启用提交模式。
    - `--message "..."`: 指定提交信息。

## 示例 (Examples)

**Agent 操作流程示例**:

1.  Agent 收到用户请求："生成并提交 Changelog"。
2.  Agent 运行: `python3 .claude/skills/changelog-generator/scripts/changelog_agent.py`
3.  Agent 获取到 Diff 输出，分析发现新增了登录功能。
4.  Agent 编辑 `CHANGELOG.md`，添加 "## [Unreleased] - ✨ 新增用户登录功能..."。
5.  Agent 运行: `python3 .claude/skills/changelog-generator/scripts/changelog_agent.py --commit --message "feat: add user login and update changelog"`

## 前置条件 (Prerequisites)

- 确保项目是一个 Git 仓库。
- 确保 `changelog_agent.py` 存在于 `.claude/skills/changelog-generator/scripts/` 目录下。
