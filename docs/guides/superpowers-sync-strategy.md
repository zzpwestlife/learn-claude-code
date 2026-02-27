# Superpowers 同步与版本管理策略 (Sync & Versioning Strategy)

本文档定义了本项目 (`learn-claude-code`) 如何与上游 `obra/superpowers` 开源项目保持同步，同时维护本地的定制化增强 (Zero-Friction Enhancements)。

## 1. 核心原则

1.  **上游优先 (Upstream First)**: 尽可能跟随上游的功能更新和 Bug 修复。
2.  **隔离定制 (Isolate Customizations)**: 将我们的定制化修改（Constitution Check, TUI Handoff, 无框架 TDD）明确标记，防止被误覆盖。
3.  **锁版本 (Lock Version)**: 使用 `.claude/superpowers.lock.json` 明确记录当前使用的上游 Commit Hash。

## 2. 版本管理机制

我们不依赖 Git Submodule，而是采用 **"Vendor + Patch"** 的轻量级管理模式：

- **Lock File**: `.claude/superpowers.lock.json`
    ```json
    {
      "repository": "https://github.com/obra/superpowers.git",
      "last_synced_commit": "e4a2375...",
      "customized_files": [
        "skills/brainstorming/SKILL.md",
        "skills/writing-plans/SKILL.md"
      ]
    }
    ```
- **Sync Script**: `.claude/scripts/sync-superpowers.py` (待实现)

## 3. 更新流程 (Update Workflow)

当需要更新 Superpowers 时，执行以下步骤：

### Phase 1: 准备 (Preparation)
1.  **创建更新分支**: `git checkout -b chore/update-superpowers`
2.  **运行同步脚本**: 
    ```bash
    python3 .claude/scripts/sync-superpowers.py --check
    ```
    脚本会拉取上游最新代码，并生成差异报告 (Diff Report)。

### Phase 2: 评估与合并 (Assessment & Merge)
3.  **自动合并**: 对于 `customized_files` 列表**之外**的文件，脚本直接覆盖更新。
4.  **手动合并**: 对于 `customized_files` 列表**之内**的文件（如 `brainstorming/SKILL.md`），脚本会生成 `.rej` 文件或尝试 3-way merge，需要人工介入解决冲突。
    *   *重点保留*: Constitution Check 逻辑, TUI 提示, TDD 环境适配。
    *   *引入上游*: 新的 Prompt 技巧, Bug 修复。

### Phase 3: 验证 (Verification)
5.  **回归测试**:
    *   运行 `/brainstorm` 确保 Constitution Check 依然触发。
    *   运行 `/writing-plans` 确保 TUI Handoff 依然触发。
    *   运行 `/systematic-debugging` 确保新功能可用。

### Phase 4: 发布 (Release)
6.  **更新 Lock File**: 脚本自动更新 `superpowers.lock.json` 中的 commit hash。
7.  **提交代码**: Merge 到主分支。

## 4. 回滚机制 (Rollback)

如果更新后发现严重问题：
1.  **Git Revert**: `git revert <merge-commit>`
2.  **Lock File 恢复**: 确保 `superpowers.lock.json` 回退到旧版本，以便下次同步脚本能正确识别基准。

## 5. 目录结构对照

| 本地路径 | 上游对应路径 | 说明 |
| :--- | :--- | :--- |
| `.claude/skills/*` | `skills/*` | 核心能力 |
| `.claude/commands/*` | `commands/*` | 快捷指令 |
| `.claude/hooks/superpowers-session-start` | `hooks/session-start` | 启动钩子 |

## 6. 常见冲突点

*   **SKILL.md**: 我们在 Prompt 中注入了额外的 `<rules>` 或 `<steps>`。
*   **Hooks**: 我们修改了脚本路径以适应扁平化结构。

---
**维护者注**: 每次更新前，请务必阅读 `docs/superpowers-guide.md` 中的 "Zero-Friction Enhancements" 章节，那是我们必须守护的核心资产。
