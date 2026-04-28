# Skill 优化方案（Batch 2）：design-first

目标：对齐微信文章《Skill 到底能蒸馏我们的几分之几？》的结论（Detailed > Comprehensive、反模板锚定、S=(C,π,T,R)），让 design-first：
- 更可复用（R 合同明确：产物/模板/决策日志）
- 更少口号过载（收敛 L2 重复强调）
- 更不容易“流程正确但不落地”（Anti-Anchoring：先 MVP 再迭代）

当前文件：`.claude/skills/design-first/SKILL.md`

---

## 现状审计结论（简版）

强项：
- C/π/T 很强：有误触发降级、复杂度分级（L/M/H）、门控、回退路径、占位符检查等

主要问题（对齐微信文章）：
1) **Comprehensive 过载风险**：规则/口号密集，易占用上下文带宽。  
2) **R 不够显式**：虽然写了 spec 内容结构与批准摘要，但缺少作为“可调用接口”的明确合同（产物清单、最小模板、输出格式）。  
3) **Anti-Anchoring不足**：缺少明确声明“不要为了显得严谨而做过度设计/过度追问”，应该先收敛 MVP 设计再迭代。  

---

## 章节级别改造方案（最小 diff）

### 1) Frontmatter：description 收敛（减少误路由）
压缩到 3-5 行：
- 触发：需要做架构/技术方案，或变更行为但需求/约束未清
- 降级：已批准 spec → writing-plans；要执行 → executing-plans；要审查 → code-review；纯信息/小修 →直接处理
- 输出：复杂度级别 + 推荐方案对比 + spec + 批准摘要（作为 R 合同的一部分）

### 2) 新增 “Reusable Interface (R) — Design Deliverables Contract”
明确最小可复用产物（让下游写计划/执行/复核更容易）：

**Required outputs (at minimum)**
1) **Complexity classification**: L/M/H + 理由（1-3 条）
2) **Options table**: 2-3 个方案（工作量/风险/回滚/依赖），包含一个最小化选项
3) **Spec file**（M/H 级）：`docs/specs/YYYY-MM-DD--{feature}.md`（或用户偏好路径）
4) **Approval Summary**（阶段6的摘要块，固定格式）
5) **Decision Log**（3-5 个关键决策：选项+理由）

### 3) 新增 “Anti-Anchoring（反锚定）” 小节（紧跟 R，小而硬）
要点：
- 不为“显得全面”而堆规则：优先把 MVP 路径说清，再列 1-2 个关键风险/降级
- 追问最多每轮 3 个关键问题（只问会改变架构/范围/验证门的问题）
- 模板/例子是结构演示，不是必须照抄；以项目现状与约束为准

### 4) 收敛 L2 口号：把重复的“必须/禁止/口号”合并成一个硬规则块
目标：保留铁律与门控，但删除/合并重复叙述，减少带宽占用。

### 5) 增加 1-2 个范例锚点（少量）
新增 Examples（Good）：
- L 级：1 问→1 段设计→批准摘要（示例）
- M 级：≤3 问→2-3 方案→3 段设计→spec→批准摘要（示例）

---

## 验证方式（改完后怎么证明有效）

1) 用户请求到达后，能快速输出 L/M/H 定级 + 2-3 方案表 + 批准摘要（R 合同落地）。  
2) 不会为了“看起来严谨”无限追问；每轮集中在 2-3 个关键决策点。  

