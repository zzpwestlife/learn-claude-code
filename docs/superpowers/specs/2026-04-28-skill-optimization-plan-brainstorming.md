# Skill 优化方案（Batch 2）：brainstorming

目标：按微信文章《Skill 到底能蒸馏我们的几分之几？》的结论优化 brainstorming：
- **收敛 L2 口号/情绪化强调**（避免“Comprehensive 过载”与冗余）
- 强化 **C（triage/降级）**：更快判断该不该进入 design loop
- 补强 **R（可复用接口）**：让 brainstorming 产物（研究/决策/规格）可被 writing-plans/executing-plans 直接复用
- 增加少量高质量 **范例锚点**（“像这样做”优于抽象口号）

当前文件：`.claude/skills/brainstorming/SKILL.md`

---

## 现状审计结论（简版）

强项：
- C/T 已较强：有 triage downgrade、强 HARD-GATE（未批准设计不得实现）
- 流程完整：research → interview → approaches → spec → review gate → transition

主要问题（对齐微信文章）：
1) **L2 口号/重复强调过多**：同一约束以多种说法反复出现，增加上下文带宽占用。  
2) **R 不够显式**：虽然写了要产出 research/spec，但缺少“固定模板/最小交付物清单”，下游复用成本高。  
3) **缺 Anti-Anchoring**：需要明确“不要为了显得严谨而无限追问/无限扩展范围”；设计要先收敛到 MVP 再迭代。  

---

## 章节级别改造方案（最小 diff，避免重写）

### 1) Frontmatter：description 收敛到 2-3 行
- 触发：用户要“做/改功能”且存在多方案/风险/需求不清，需要先设计
- 硬门槛：若只是解释/小修/已有明确且批准的方案 → STOP 降级到合适 skill
- 输出：research note + decision log + spec（并通过 AskUserQuestion gate）

### 2) 新增 “Reusable Interface (R) — Brainstorming Deliverables Contract”
明确最小可复用产物：
1) `docs/research/YYYY-MM-DD-<topic>.md`（仅包含：现状/约束/风险/可选方案）
2) `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`（spec）
3) **Decision Log（小模板）**：记录 2-3 个关键决策与理由（用于后续追溯）

### 3) 新增 “Anti-Anchoring（反锚定）” 小节（紧跟 R，小而硬）
要点：
- 不为“显得全面”而无限追问；每轮最多 3 个关键问题，优先解决会影响架构/范围/验证门的决策
- 不做“全平台/全子系统”宏大设计：先 MVP，再迭代
- 示例/流程图是结构演示，不是必须执行的仪式；以达成决策与产物为准

### 4) 收敛 L2 口号：删除重复段落/合并为 1 个硬规则块
目标：保留 HARD-GATE 与 triage，删除重复的“每个项目都必须…/不要觉得太简单…”等多次强调，把“可短”写清楚即可。

### 5) 增加 1-2 个范例锚点（少量）
新增一段“Examples（Good）”：
- **小改动（应降级，不走 design loop）**：比如“改一个文案/修一个拼写”
- **中等复杂（走 design loop）**：比如“新增一个 CI target / 新增一个报表生成器”

---

## 验证方式（改完后怎么证明有效）

1) 误触发请求（纯信息/小修）能快速降级，不强行进入 design loop。  
2) 真正进入 brainstorming 时，能在 1-2 轮对话内产出可复用的最小交付物（research + spec + 关键决策）。  

