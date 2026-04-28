# Phase 2（ratchet）总览（2026-04-28）

本文件汇总 `darwin-skill/results.tsv` 中各 skill 的 **baseline → 当前最新分** 及提升幅度，并给出下一步建议。

> 说明：当前分数均为 **dry_run（D8 为估计）**，用于相对比较与 ratchet 控制。

---

## 1) 榜单（按提升幅度排序）

| Skill | Baseline | Latest | Δ |
|---|---:|---:|---:|
| ielts | 67.0 | 90.5 | +23.5 |
| english-immersion | 57.4 | 75.5 | +18.1 |
| writing-plans | 85.3 | 88.5 | +3.2 |
| executing-plans | 85.3 | 88.3 | +3.0 |
| code-review | 82.3 | 85.3 | +3.0 |
| design-first | 88.3 | 91.3 | +3.0 |
| brainstorming | 85.0 | 87.5 | +2.5 |
| verification-before-completion | 89.0 | 90.8 | +1.8 |
| test-driven-development | 91.7 | 93.5 | +1.8 |
| systematic-debugging | 91.0 | 92.8 | +1.8 |

---

## 2) 内置 skills：Phase 2 关键改动（摘要）

这些改动整体呈现一个共同趋势：**D3（边界条件覆盖）+ D5（指令具体性）优先**，通过“误触发降级/停止规则/证据模板”降低失败模式。

- `code-review`：无 diff / 非 git 场景明确 STOP，并请求用户提供审查对象（避免输出空洞审查）。
- `brainstorming`：加入 Triage 降级 + HARD-GATE 例外（Triage 判定不适用则停止/路由），并规定“模糊时先问 1 个问题再决定”。
- `executing-plans`：加入 Triage（无 plan/仅 review/非 git）+ “缺少验证门则停止补齐”的规则。
- `writing-plans`：无已批准 spec 则 STOP 并路由 `brainstorming`；多子系统未拆分则 STOP，先让用户确认拆分后再写计划。
- `design-first`：在定级阶段增加误触发路由（writing/executing/code-review）+ 非 git 输入策略（不做 repo 假设）。
- `verification-before-completion`：强制证据模板（Claim/Command/Exit code/Evidence）+ 无环境/无命令时 STOP 与替代证据优先级。
- `systematic-debugging`：无法复现且无日志时 STOP，并给出最小证据清单；提供最小复现报告模板。
- `test-driven-development`：无法运行测试命令则 STOP（禁止进入 GREEN）；GREEN 报告必须包含命令/exit/evidence。

---

## 3) 下一步建议（从 dry_run → 实测）

Phase 2 已把“纸面规则”变得更不容易被误用。下一阶段建议做 **小规模实测 A/B**：

- 选 1–2 个典型任务类型（例如：小 bugfix / 中等改动 / 多文件重构）
- 对照执行：
  - **with-skill**：严格按 skill 的门控/模板输出
  - **without-skill**：同等投入但不引用 skill（或只用最薄规则）
- 记录差异：误触发率、返工次数、是否出现“无证据完成宣称”、沟通轮次、最终交付质量

