# 分层记忆架构指南 (Layered Memory Architecture)

本文档定义了本项目的记忆管理策略，旨在实现友好、高效、低 Token 消耗的长期记忆。

## 1. 架构概览

我们采用三层记忆模型：

| 层级 | 名称 | 存储位置 | 作用域 | 典型内容 |
| :--- | :--- | :--- | :--- | :--- |
| **Layer 1** | **Core Memory (潜意识)** | Agent System Context | User / Project | 核心规则、个人偏好、绝对禁令 |
| **Layer 2** | **Project Lessons (经验)** | `.claude/lessons.md` | Project | 踩坑记录、纠错总结、最佳实践 |
| **Layer 3** | **Task Context (工作台)** | `docs/plans/*.md` | Task | 当前任务状态、实施计划 |
| **Layer 4** | **Advanced (扩展能力)** | `.claude/skills/` & Plugins | Global / Project | 技能进化 (Claudeception)、海量回溯 (claude-mem) |

---

## 2. 详细说明

### Layer 1: Core Memory (最核心)
**特点**: 无感注入，无需读取文件，Token 消耗极低。
**使用方法**:
- **添加**: 对话中说 "请记住：以后都要用中文回复" (User级) 或 "本项目禁止使用 `any` 类型" (Project级)。
- **查看**: 问 "你现在记住了哪些规则？"
- **维护**: 使用 `manage_core_memory` 工具 (由 Agent 自动调用)。

### Layer 2: Project Lessons (经验库)
**特点**: 文本文件，可读性强，Agent 启动时查阅。
**使用方法**:
- **更新**: 当发生错误或学到新知识时，Agent 会自动追加到 `.claude/lessons.md`。
- **示例**:
  ```markdown
  - [2024-03-20] 错误: API 调用超时。教训: 所有外部请求必须设置 30s timeout。
  ```
- **维护**: 定期人工查看，删除过时条目。

### Layer 3: Task Context (当前任务)
**特点**: 随用随弃，任务完成后归档。
**使用方法**:
- **创建**: 开始任务时使用 `/writing-plans` 生成 `docs/plans/YYYY-MM-DD-feature.md`。
- **归档**: 任务完成后运行 `/finishing-a-development-branch` 自动处理。

### Layer 4: Advanced (进阶/扩展)
**定位**: 可选的增强模块，用于复杂场景。

**1. Claudeception (Skill Architect)**
- **作用**: "AI 写 AI"。将对话中产生的智慧封装为新的工具/技能。
- **场景**: 当你发现自己反复在做同一件事（如写特定的 SQL 查询）时，让 Claude 把这个过程变成一个 `/command`。
- **启用**: 已集成在 `.claude/skills/skill-architect/`。

**2. claude-mem (Episodic Memory)**
- **作用**: "海量回溯"。利用向量数据库 (ChromaDB) 存储所有历史对话。
- **场景**: 需要查找 "上个月我们在哪个文件里讨论过这个问题？"
- **启用**: 需安装插件 `npm install -g claude-mem`。

---

## 3. 维护指令

| 指令 | 作用 |
| :--- | :--- |
| `/tidy-memory` | 整理记忆。去重 `lessons.md`，并提示清理 Core Memory。 |
| `/archive-task` | 归档当前任务文件，保持根目录整洁。 |

## 4. 常见问题 (FAQ)

**Q: `~/.claude/memory/` 是什么？**
A: 这是 User 级别的记忆存储目录。如果您的环境支持 Auto Memory，它会自动维护 `MEMORY.md`。如果不支持，Agent 会模拟此行为。

**Q: 如何减少 Token 消耗？**
A:
1. 仅将**高频、通用**的规则放入 Core Memory。
2. 细节知识放入 `lessons.md` 或文档。
3. 任务完成后及时归档 `task_plan.md`。

**Q: User 和 Project 级别怎么分？**
- **User**: "我喜欢 TypeScript" (跨项目通用)。
- **Project**: "这个项目用 Next.js 14" (仅本项目有效)。
