# Skill 优化方案（Batch 1）：executing-plans

目标：补齐 **R（可复用接口）**，并把“执行计划”从“流程描述”升级为“可编排、可验证、可复用的交付物流水线”，贴合文章所说的 L1（确定性注入）与“终止条件（T）”的重要性。

当前文件：`.claude/skills/executing-plans/SKILL.md`

---

## 现状问题（来自审计 + 文章启发）

优点：
- C/π/T 都比较强（triage、mode selection、finish branch、stop rules）

需要补强：
1) **R 偏弱**：缺“固定产出格式”，导致执行结果不可复用/不可审计（文章强调可组合/可路由，R 是关键）。  
2) **对 verification-before-completion 的接口引用不够硬**：提到 verification gate，但缺“强制证据块”。  
3) **示例偏少**：需要少量“执行日志/证据块范例”，用于 L2 定锚点，但不要堆模板（避免锚定）。  

---

## 章节级别改造方案（最小 diff）

### 1) Frontmatter：description 更明确地声明“交付物”
在 description 里明确：
- 输入：plan 文件路径（必须存在）
- 输出：任务清单 + 分支状态 + 每步证据块

### 2) 新增一个“R：可复用接口（Mandatory Outputs）”小节（放在 Process 之前或之后）
新增小节建议标题：
#### Reusable Interface (R): Execution Transcript Contract

内容要点（固定格式）：
1) **Task list contract**
   - TodoWrite：每个任务状态必须可追踪（pending/in_progress/completed）
2) **Step evidence contract**（直接引用 vbc 的 Evidence Template）
   - 每个“完成宣称/通过宣称/阶段结束”都必须带证据块
3) **Chunk boundary contract**
   - 每个 chunk 完成后必须展示：`git diff --stat`（或等价的文件变更摘要）
4) **Finish contract**
   - 合并/PR/保留/丢弃 4 选 1，且丢弃需要 typed confirm

### 3) 把 “Triage (mis-trigger downgrade path)” 做成更短的 1-2 层决策树
保持现有条目，但做两点优化：
- 加一个“最少提问集”（缺 plan / 缺 repo / 缺验证命令分别问什么）
- 明确：缺验证命令时必须路由到 `verification-before-completion` 产出“verification gate”

### 4) 增加 1 个 “Anti-anchoring” 段落（非常短）
强调：
- plan 是约束，不是“模板照抄”
- 任何示例命令/示例输出与现实冲突时，以现实为准；需要重新验证

---

## 验证方式（改完后怎么证明有效）

1) 在后续真实任务中，执行链路产物应满足 R 合同：
   - TodoWrite 可追踪
   - 每个完成宣称都有证据块
   - `git diff --stat` 分段出现
2) 用 Round4 的 CI/构建链路任务复用该结构：把 make ci 的每步输出映射到证据块

