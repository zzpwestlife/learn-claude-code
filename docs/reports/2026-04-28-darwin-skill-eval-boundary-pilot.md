# darwin-skill 结构评估对比报告（边界声明试点）

**日期**：2026-04-28  
**评估对象**：`.claude/skills/brainstorming/SKILL.md`、`.claude/skills/writing-plans/SKILL.md`  
**变更类型**：仅修改 frontmatter `description`，补齐 `Invoke when / Do not use when / Examples`（不改正文流程）  
**对比范围**：修改前（commit `HEAD~1`） vs 修改后（commit `HEAD`）  

> 说明：本报告按 darwin-skill rubric 的 **维度 1–7** 做“静态结构评估”。维度 8（实测表现）需要测试 prompts + baseline/with-skill 对比，本轮不评估，因此总分以 **1–7 子总分（满分 75）**呈现。

---

## Rubric（维度 1–7）与权重

| 维度 | 名称 | 权重 |
|---:|---|---:|
| 1 | Frontmatter 质量 | 8 |
| 2 | 工作流清晰度 | 15 |
| 3 | 边界条件覆盖（含触发边界声明） | 10 |
| 4 | 检查点设计 | 7 |
| 5 | 指令具体性 | 15 |
| 6 | 资源整合度 | 5 |
| 7 | 整体架构 | 15 |

计算方式（与 darwin-skill 一致）：  
**子总分（1–7，满分 75）= Σ(维度分 1–10 × 权重) / 10**

---

## 评估结果总览

### A) brainstorming

| 维度 | 分数（前） | 分数（后） | 变化 |
|---:|---:|---:|---:|
| 1 Frontmatter | 6 | 8 | +2 |
| 2 工作流清晰度 | 9 | 9 | 0 |
| 3 边界条件覆盖 | 6 | 8 | +2 |
| 4 检查点设计 | 9 | 9 | 0 |
| 5 指令具体性 | 9 | 9 | 0 |
| 6 资源整合度 | 8 | 8 | 0 |
| 7 整体架构 | 9 | 9 | 0 |

**子总分（1–7）**：61.6 → **65.2**（**+3.6 / 75**）

要点说明：
- 维度 1 提升：description 从“单句强制规则”升级为可路由的结构化声明（含例子）。
- 维度 3 提升：新增明确的 **Do not use when**，符合 darwin-skill rubric 中“触发边界声明”的要求，降低误触发带来的流程摩擦。

### B) writing-plans

| 维度 | 分数（前） | 分数（后） | 变化 |
|---:|---:|---:|---:|
| 1 Frontmatter | 5 | 8 | +3 |
| 2 工作流清晰度 | 9 | 9 | 0 |
| 3 边界条件覆盖 | 6 | 8 | +2 |
| 4 检查点设计 | 8 | 8 | 0 |
| 5 指令具体性 | 9 | 9 | 0 |
| 6 资源整合度 | 8 | 8 | 0 |
| 7 整体架构 | 9 | 9 | 0 |

**子总分（1–7）**：60.1 → **64.5**（**+4.4 / 75**）

要点说明：
- 维度 1 提升更明显：原 description 过短，只表达“何时用”，缺少“不适用”与 examples；补齐后更利于路由与避免误用。
- 维度 3 同样因新增边界声明提升：明确“需求未定用 brainstorming、执行计划用 executing-plans”。

---

## 结论

1. 本轮仅改 frontmatter，但对 darwin-skill 的结构评分体系来说是“可测量的正向改进”，主要体现在：
   - **Frontmatter 质量（维度1）**
   - **边界条件覆盖/触发边界声明（维度3）**
2. 由于未做维度 8（实测表现），本报告不对“最终端到端效果”做强结论；但对这类“路由/流程治理型技能”，结构评分的提升通常对应 **误触发降低** 与 **使用成本下降**，方向合理。

---

## 建议的下一步（可选）

- 将同一模板推广到其余内置 skills（优先：`executing-plans`、`test-driven-development`、`verification-before-completion`、`code-review`）。
- 统一约束：description 保持短小（每段 2–4 条 bullet + 2 条 examples），避免从“边界声明”滑向“comprehensive 大段解释”。

