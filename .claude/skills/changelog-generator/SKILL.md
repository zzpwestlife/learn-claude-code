---
name: "changelog-generator"
description: "通过分析当前分支与主分支 (main/master) 之间的 Git 历史差异，生成或预览项目变更日志。当用户需要更新 CHANGELOG.md 或查看近期变更时调用此技能。"
---

# 变更日志生成器 (Changelog Generator)

本 Skill 使用 `changelog_agent.py` 脚本分析 **当前分支与主分支 (main/master)** 之间的 Git 差异，并生成符合语义化版本规范的变更日志。

## 用法 (Usage)

当用户请求生成、更新或预览变更日志时，使用 `RunCommand` 工具运行 `changelog_agent.py` 脚本。

### 命令 (Commands)

1. **预览变更 (Preview Changes / Dry Run)**
   - 适用场景：用户希望在不修改文件的情况下查看将要生成的变更内容。
   - 命令：`python3 .claude/skills/changelog-generator/scripts/changelog_agent.py --dry-run`

2. **生成/更新变更日志 (Generate/Update Changelog)**
   - 适用场景：用户明确希望更新 `CHANGELOG.md` 文件。
   - 命令：`python3 .claude/skills/changelog-generator/scripts/changelog_agent.py`

3. **指定版本 (Specify Version)**
   - 适用场景：用户提供了具体的版本号（例如 v1.0.0）。
   - 命令：`python3 .claude/skills/changelog-generator/scripts/changelog_agent.py --version <version>`

4. **包含未提交变更 (Include Uncommitted Changes)**
   - 适用场景：用户希望将当前工作区未提交的代码变更一并纳入 Changelog 并提交。
   - 命令：`python3 .claude/skills/changelog-generator/scripts/changelog_agent.py --commit --message "feat: new feature description"`

5. **生成并提交 (Generate and Commit)**
   - 适用场景：用户希望自动提交生成的变更。
   - 命令：`python3 .claude/skills/changelog-generator/scripts/changelog_agent.py --commit`

## 前置条件 (Prerequisites)

- 确保 `changelog_agent.py` 存在于 `.claude/skills/changelog-generator/scripts/` 目录下。
- 确保当前分支为功能分支（非 main/master），或者指示用户切换分支。
