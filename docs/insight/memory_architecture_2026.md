# 2026 Agent 记忆工程趋势与本项目架构映射

基于 2026 年 Agent 记忆工程的 4 大类型共识，对 `Learn Claude Code` 项目当前的记忆架构（Layer 1-4）进行映射分析与演进规划。

## 核心共识
> Agent 的核心瓶颈已从“模型能力”转向“记忆/状态工程”。核心目标是：长期保持状态、积累经验、避免幻觉和漂移。

## 架构映射分析

我们将业界的 4 大类型与本项目的 `FlowState` 记忆架构进行对比：

| 业界标准类型 | 核心特征 | 本项目对应实现 | 现状评估 & 启示 |
| :--- | :--- | :--- | :--- |
| **Type 1: 日常记忆**<br>(Basic RAG) | 短期对话 + 外挂知识库 (RAG)。<br>像人类一样记笔记、查资料。 | **基础环境**<br>- IDE 上下文 (Cursor/Claude)<br>- 项目文件树<br>- `docs/` 文档库 | ✅ **已就绪**<br>这是项目的基础设施。启示是需保持 `docs/` 目录结构的语义清晰，以便模型能精准检索（"File-centric RAG"）。 |
| **Type 2: 聪明加速记忆**<br>(Smart Caching) | Prefix Cache + 模板变量。<br>降低 Token 消耗，提高速度。 | **🔧 配置优化**<br>- `SessionStart Hook 精简`<br>- 结构化 Prompt (`prompt.md`) | ⚠️ **需强化**<br>目前的优化主要在减少 Context。启示是应更利用 "Prefix Caching" 特性，将静态规则（如 `constitution.md`）置于 Prompt 头部固定，动态状态置于尾部。 |
| **Type 3: 智能管家记忆**<br>(Agentic Memory) | 核心记忆 (Core) + 回忆 (Recall) + 归档 (Archival)。<br>Agent 自我管理、自动总结、遗忘。 | **🧩 记忆架构 (Layer 1-3)**<br>- Layer 1: `Core Memory` (用户偏好/规则)<br>- Layer 2: `lessons.md` (经验积累)<br>- Layer 3: `task_plan.md` (动态状态)<br>- Cmd: `/tidy-memory`, `/archive-task` | 🔄 **核心发力点**<br>本项目架构与 Type 3 高度契合。<br>**启示**：目前 `/tidy-memory` 偏向手动。未来应向 **"主动式管家"** 进化，即 Agent 在任务结束时自动建议归档内容，而非被动等待指令。 |
| **Type 4: 超级持久记忆**<br>(Infinite/Graph) | 无限上下文 + 文件中心持久状态 + 图数据库。<br>终身记忆，复杂关系管理。 | **Layer 4 & FlowState**<br>- **File-centric State**: `docs/plans/` 作为单一真理来源<br>- `claude-mem` (向量回溯)<br>- `Claudeception` (技能进化) | 🌟 **长期方向**<br>项目坚持的 "Atomic Execution" 和 "File-First" 策略正是 Type 4 中 **"文件中心持久状态" (InfiAgent)** 的体现。<br>**启示**：继续强化以文件为中心的“状态持久化”，这是对抗上下文漂移的终极手段。 |

## 关键启示与行动项 (Action Items)

### 1. 坚定 "File-First" 路线 (Type 4 启示)
业界趋势证明，**"文件即状态" (File-centric persistent state)** 是解决长程任务遗忘和漂移的最佳实践。
*   **Action**: 继续强制执行 `docs/plans/` 和 `docs/design/` 的实时更新，将其视为 Agent 的"外挂海马体"，而非仅仅是文档。

### 2. 增强 "主动归档" 能力 (Type 3 启示)
目前的记忆整理依赖用户触发（`/tidy-memory`）。
*   **Action**: 在 `workflow-protocol.md` 中，将“记忆整理”提升为任务结束的标准动作（Step 6 Changelog 之后，Step 7 Commit 之前）。Agent 应主动询问：“本次任务有哪些 `lessons` 值得记录到 Layer 2？”

### 3. 结构化 Prompt 以利用缓存 (Type 2 启示)
为了适应 "Smart Caching"，Prompt 结构应分层。
*   **Action**: 确保 `CLAUDE.md` 和核心规则在 Context 头部保持稳定，将变动最频繁的 `User Input` 和 `Current Task State` 放在尾部，最大化缓存命中率。

### 4. 知识图谱化的潜力 (Type 4 进阶)
随着 `lessons.md` 变长，线性查找效率会下降。
*   **Action**: 远期考虑将 `lessons.md` 结构化（如 Tag 索引），或引入轻量级 Graph 关联（通过 Wiki Links `[[Topic]]`），为未来引入 GraphRAG 做准备。
