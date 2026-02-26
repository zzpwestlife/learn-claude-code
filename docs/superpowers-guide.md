# Superpowers Guide

[Superpowers](https://github.com/obra/superpowers) 是目前 Claude Code 生态中最成熟的 Skill 管理和工作流增强方案。本项目已完全集成 Superpowers，替代了原有的 `planning-with-files`。

## 核心理念 (Core Philosophy)

Superpowers 将 Claude 从简单的代码补全工具升级为具备系统方法论的高级 AI 开发者。它强制执行以下工程原则：

1.  **Thinking before Coding**: 在写代码前必须先进行 `/brainstorming` 和 `/writing-plans`。
2.  **Test Driven Development (TDD)**: 强制遵循 Red-Green-Refactor 循环。先写失败的测试，再写实现。
3.  **Systematic Debugging**: 禁止猜测式修复。必须先定位根因 (Root Cause)，再实施修复。
4.  **Subagent Collaboration**: 复杂任务由多个专职 Subagent（Spec Reviewer, Code Reviewer, Implementer）协作完成。

## 常用指令 (Key Commands)

| 指令 | 作用 | 对应阶段 |
| :--- | :--- | :--- |
| `/brainstorming` | 需求分析与设计。通过苏格拉底式提问澄清需求。 | Step 1: Design |
| `/writing-plans` | 生成详细的实施计划。将任务拆解为 2-5 分钟的微任务。 | Step 2: Plan |
| `/execute-plans` | 批量执行计划。调用 Subagents 进行开发与自我审查。 | Step 3: Execute |
| `/systematic-debugging` | 系统化调试。包含复现、根因分析、修复、验证四个阶段。 | Debugging |
| `/requesting-code-review` | 请求代码审查。在合并代码前进行质量检查。 | Review |

## 工作流变更 (Workflow Changes)

原有的 `planning-with-files` 工作流已被 Superpowers 取代：

*   **旧流程**: `/optimize-prompt` -> `/planning-with-files plan` -> `/planning-with-files execute`
*   **新流程**: `/brainstorming` -> `/writing-plans` -> `/execute-plans` (或 `/subagent-driven-development`)

## 调试指南 (Debugging Guide)

当遇到 Bug 时，**不要直接修复**。请使用以下 Prompt 触发系统化调试：

> "Systematic debugging: [描述你的问题]"

Claude 会启动 `systematic-debugging` skill，引导你完成：
1.  **Reproduction**: 最小化复现步骤。
2.  **Root Cause Analysis**: 追踪数据流，定位根本原因。
3.  **Fix Implementation**: 编写测试用例并修复。
4.  **Verification**: 验证修复效果。

## 更多资源

*   [Superpowers GitHub 仓库](https://github.com/obra/superpowers)
*   [Superpowers 插件主页](https://claude.com/plugins/superpowers)
