# 微信文章「让 Skill 自己训练自己」与 darwin-skill 仓库映射清单

## 目的

把微信文章中关于“Skill 要像工程资产一样持续训练”的主张，映射到本仓库已具备能力、能力缺口与建议试点，作为后续研究和执行的对照底稿。

## 关系说明

这篇“自进化”文章与前一篇“Skill 蒸馏”文章不是重复关系，而是上下游关系：

| 维度 | 旧文章《Skill 到底能蒸馏我们的几分之几？》 | 新文章《让 Skill 自己训练自己》 | 在本仓库中的对应关系 | 证据路径 |
|---|---|---|---|---|
| 关注重点 | 关注“Skill 应该如何写好”，核心是把人的经验蒸馏成可触发、可执行、可终止、可复用的技能单元。 | 关注“Skill 写出来以后如何持续变好”，核心是评估、对照、keep/revert、记录产物、逐轮演进。 | 前者解决“写得对不对”，后者解决“能不能持续变好”。仓库当前已经把旧文章的方法论转成一批内置 skill 的改造项，而新文章对应的自进化闭环只完成了骨架。 | `docs/research/2026-04-28-wechat-skill-optimization-checklist.md`；`docs/research/2026-04-28-skill-audit-from-wechat.md`；`docs/superpowers/specs/2026-04-28-skill-phase2-ratchet.md`；`docs/reports/2026-04-29-skill-optimization-summary.md` |
| 主要方法 | `S=(C, π, T, R)`、避免 Comprehensive 过载、Anti-Anchoring、最短可复现路径。 | Rubric 评分、baseline/round 对照、严格提升才 keep、失败即 revert、结果写入 `results.tsv`。 | 旧文方法已经进入 `code-review`、`writing-plans`、`brainstorming` 等技能的 round3 改进；新文方法已经进入 `darwin-skill` 的 ratchet 方案，但实测覆盖与 self-host 仍不足。 | `docs/research/2026-04-28-wechat-skill-optimization-checklist.md`；`docs/reports/2026-04-28-darwin-skill-eval-code-review-round3.md`；`docs/reports/2026-04-28-darwin-skill-eval-writing-plans-round3.md`；`docs/superpowers/specs/2026-04-28-skill-phase2-ratchet.md`；`.claude/skills/darwin-skill/results.tsv` |
| 当前仓库阶段 | 旧文章对应的是“把 Skill 写成合格工程资产”的阶段。 | 新文章对应的是“让 Skill 进入可追踪、可复盘、可自演进”的阶段。 | 仓库已基本完成前一阶段的主干建设，但后一阶段仍停留在“有评估与 keep/revert 机制，尚未全面实测、尚未自训自身”的状态。 | `docs/reports/2026-04-29-skill-optimization-summary.md`；`docs/reports/2026-04-28-skill-ab-eval-results.md`；`docs/superpowers/specs/2026-04-28-skill-phase2-ratchet.md` |

## 对照依据

- 外部文章转述：CSDN《从创建到进化：用 skill-creator 和 Darwin 打造高质量 Agent Skill》
- 仓库内主证据：`.claude/skills/darwin-skill/SKILL.md`、`.claude/skills/darwin-skill/README.md`
- 仓库内过程证据：`.claude/skills/darwin-skill/results.tsv`、`docs/reports/*darwin-skill-eval-*.md`
- 仓库内研究证据：`docs/research/2026-04-28-skill-audit-from-wechat.md`、`docs/research/2026-04-28-wechat-skill-optimization-checklist.md`

## 状态标签

- `已具备`：仓库里已有明确机制，且能找到产物或执行记录
- `部分具备`：已经有设计、局部样例或部分执行，但尚未覆盖主路径
- `缺失`：研究里已指出，但仓库仍未形成稳定机制

> 说明：“建议试点”保留为独立分组，不再作为状态标签使用。

## 一、已有基础

| 条目 | 映射说明 | 证据路径 | 状态 |
|---|---|---|---|
| 单一可编辑资产 + 资源目录化 | 新文章强调 Skill 不是随手 Prompt，而是包含 `SKILL.md`、脚本、参考资料、资产的工程单元；本仓库 `darwin-skill` 已按该结构组织，并把 `SKILL.md` 作为主优化对象。 | `.claude/skills/darwin-skill/README.md`；`.claude/skills/darwin-skill/SKILL.md` | 已具备 |
| 棘轮式 keep / revert 机制 | 新文章强调“只保留真正变好的修改”；仓库已把 `keep` / `revert` 和 `results.tsv` 作为 ratchet 主线，并在 Phase 2 方案中写成硬规则。 | `.claude/skills/darwin-skill/SKILL.md`；`.claude/skills/darwin-skill/results.tsv`；`docs/superpowers/specs/2026-04-28-skill-phase2-ratchet.md` | 已具备 |
| 结构评分 + 效果评分双轨评估 | 新文章要求不要只看格式，还要看实际效果；`darwin-skill` 已定义 8 维 rubric，区分结构维度与效果维度，并把 round 报告沉淀到 `docs/reports/`。 | `.claude/skills/darwin-skill/README.md`；`.claude/skills/darwin-skill/SKILL.md`；`docs/reports/2026-04-28-darwin-skill-eval-code-review-round3.md` | 已具备 |
| 人在回路的优化检查点 | 新文章把人工判断作为防漂移手段；本仓库在 README 与 SKILL 中都明确要求每个 skill 优化后暂停，等待用户确认再继续。 | `.claude/skills/darwin-skill/README.md`；`.claude/skills/darwin-skill/SKILL.md` | 已具备 |
| 旧文章方法论已映射进多个 skill | 旧文章中的 `S=(C, π, T, R)`、Anti-Anchoring、避免 Comprehensive 过载，已经转成 `writing-plans`、`code-review` 等技能的真实改动与提分记录，为“自进化”提供了可迭代底座。 | `docs/research/2026-04-28-wechat-skill-optimization-checklist.md`；`docs/research/2026-04-28-skill-audit-from-wechat.md`；`docs/reports/2026-04-28-darwin-skill-eval-writing-plans-round3.md`；`docs/reports/2026-04-28-darwin-skill-eval-code-review-round3.md`；`.claude/skills/darwin-skill/results.tsv` | 已具备 |

## 二、能力缺口

| 条目 | 差距说明 | 证据路径 | 状态 |
|---|---|---|---|
| 大多数评估仍停留在 `dry_run` | 新文章要求“实际测试后再保留修改”，但当前大部分 baseline、round1-3 报告仍把 D8 标成 `dry_run` 估计分，真实对照执行不足。 | `.claude/skills/darwin-skill/results.tsv`；`docs/reports/2026-04-29-skill-optimization-summary.md`；`docs/reports/2026-04-28-darwin-skill-eval-writing-plans-round3.md`；`docs/reports/2026-04-28-phase2-summary.md` | 部分具备 |
| `test-prompts.json` 覆盖面不足 | `darwin-skill` 设计里把测试集视为核心输入，但仓库内只有少数 skill 具备 `test-prompts.json`，尚未形成“每个目标 skill 都有测试集”的常态。 | `.claude/skills/darwin-skill/SKILL.md`；`.claude/skills/design-first/test-prompts.json`；`.claude/skills/english-immersion/test-prompts.json`；`.claude/skills/neat-freak/test-prompts.json`；`.claude/skills/lark-doc-copywriting/test-prompts.json` | 部分具备 |
| 合同类约束还缺自动门禁 | 研究与总结已经建议把 frontmatter、R 合同、Anti-Anchoring 做成 lint/CI 门禁，但目前仍停留在“下一步建议”，没有看到对应检查器落地。 | `docs/reports/2026-04-29-skill-optimization-summary.md`；`docs/superpowers/specs/2026-04-28-skill-boundary-template-design.md` | 缺失 |
| `darwin-skill` 还没有进入“自训练自身”闭环 | Phase 2 方案明确把内置 skills 纳入 ratchet，但也明确写了 `darwin-skill` 本身不在本轮范围内，所以“让优化器先优化自己”还没有被真正试跑。 | `docs/superpowers/specs/2026-04-28-skill-phase2-ratchet.md` | 缺失 |

## 三、建议试点（按优先级/顺序）

| 优先级 | 条目 | 试点目标 | 排序理由 | 证据路径 | 当前状态 |
|---|---|---|---|---|---|
| P1 / 第 1 顺位 | 为执行链路技能补齐真实对照测试 | 优先给 `executing-plans`、`verification-before-completion`、`test-driven-development` 补 `test-prompts.json` 与 `with-skill / baseline` 对照，先把最常用链路从 `dry_run` 升级为可复现实测。 | 这是“自进化”能否成立的基础前提；如果 D8 仍主要依赖估计分，后续 keep/revert 与 self-host 结论都不够硬。 | `.claude/skills/darwin-skill/SKILL.md`；`docs/reports/2026-04-28-skill-ab-eval-results.md`；`docs/reports/2026-04-29-skill-optimization-summary.md` | 部分具备 |
| P2 / 第 2 顺位 | 以 `darwin-skill` 自身做一次 self-host ratchet | 最小化验证“让 Skill 自己训练自己”是否能在本仓库闭环成立；建议只选 1 个最低分维度，沿用现有 `keep/revert/results.tsv` 机制。 | 这是新文章与旧文章的关键分水岭。只有优化器开始优化自己，仓库才算真正进入“自进化”阶段。 | `.claude/skills/darwin-skill/SKILL.md`；`docs/superpowers/specs/2026-04-28-skill-phase2-ratchet.md` | 缺失 |
| P3 / 第 3 顺位 | 把 `Evidence Block` 升级为跨 skill 的统一协议 | 让 `code-review`、`systematic-debugging`、`test-driven-development`、`verification-before-completion` 的产物能串联复用，并为后续 lint/CI 提供固定字段。 | 统一协议能把“单点优化”升级为“链路级优化”，也是后续自动评估与门禁的共用底座。 | `docs/reports/2026-04-29-skill-optimization-summary.md`；`docs/reports/2026-04-28-darwin-skill-eval-code-review-round3.md`；`.claude/skills/darwin-skill/results.tsv` | 部分具备 |
| P4 / 第 4 顺位 | 将“合同检查”前移到 lint/CI | 试点目标不是一次性全覆盖，而是先检查三项最稳定字段：frontmatter、R 合同、Anti-Anchoring；避免 round3 成果在后续改动中回退。 | 这是防回退工程化步骤，优先级低于“先补实测、再做 self-host”，但一旦试点成功，能把结果固化。 | `docs/reports/2026-04-29-skill-optimization-summary.md`；`docs/research/2026-04-28-wechat-skill-optimization-checklist.md` | 缺失 |

## 结论

当前仓库已经具备“Skill 作为工程资产被持续优化”的主体骨架：有 rubric、有 ratchet、有报告，也已经把旧文章“Skill 蒸馏”的关键方法论落实到一批核心技能上。真正还缺的是把新文章“Skill 自进化”的后半段补齐，即把 `dry_run` 升级为稳定实测、让 `darwin-skill` 自身进入一次 self-host ratchet、再把统一合同前移为门禁。
