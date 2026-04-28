# Phase 2（Ratchet）Skill 优化执行方案（2026-04-28）

## Goal

在已建立 dry_run baseline 的前提下，对当前项目内置 skills 进入 darwin-skill 的 Phase 2：

> 找到最低分维度 → 做 1 个最小、可归因的改动 → 复评分（dry_run）→ **严格提升才保留**（否则回滚）→ 记录到 `results.tsv`

本轮以“**刀磨锋利 + 避免 Comprehensive 陷阱**”为原则，优先改进 L1/L1.5 可执行与边界声明，避免编码 L2/Utility 的长篇权衡。

---

## Scope

仅优化当前仓库内置 skills（不含第三方）：
- `code-review`（当前最低 baseline，优先）
- `executing-plans`
- `brainstorming`
- `writing-plans`
- `design-first`
- `verification-before-completion`
- `systematic-debugging`
- `test-driven-development`

> 注：`darwin-skill` 本身不在本轮 ratchet 范围内。

---

## Constraints

- **每个 skill 最多 2 轮**（用户确认）。
- 每轮只做 **1 个最小改动**（单一可编辑资产、变量可控、改进可归因）。
- 评分采用 **磨过的 darwin-skill rubric**：
  - D1 要求 Invoke/Do not/Examples
  - D3 强调“误触发降级策略”
  - D5 强化 anti-distill 空话扣分
  - 仍以 dry_run 为主（D8 为估计分，报告明确标注）
- **Ratchet**：总分必须 **严格高于**该 skill 当前 baseline 才 keep，否则 revert。

---

## Order（执行顺序）

默认按 baseline 从低到高推进（先修收益最大者）：
1) `code-review`（82.3）
2) `brainstorming`（85.0）
3) `executing-plans`（85.3）
4) `writing-plans`（85.3）
5) `design-first`（88.3）
6) `verification-before-completion`（89.0）
7) `systematic-debugging`（91.0）
8) `test-driven-development`（91.7）

---

## Phase 2 执行循环（每个 skill）

对每个 skill，最多 2 轮：

### Round N（N=1..2）
1. **诊断最低分维度**
   - 从最近的 baseline 报告读取 D1–D8，找最低/最可改的维度（通常是 D3 或 D5）。
2. **提出 1 个最小改动**
   - 目标：提升该维度 1–2 分；避免引入冗余文字与“权衡口号”。
   - 改动类型优先级：
     - D3：补齐“误触发时怎么降级”的明确动作（停止/切换 skill/请求用户提供 diff/计划路径等）
     - D5：把抽象句替换为可执行判据/示例锚点
     - D2：补齐缺失的输入/输出/命令（仅在明显缺口时）
3. **实施改动并提交**
   - commit message：`optimize(<skill>): <short-change>`
4. **dry_run 复评分**
   - 更新/新增 `docs/reports/` 下该 skill 的 round 报告（记录维度分、总分、变化原因）。
5. **Keep/Revert**
   - 若新总分 > 当前 baseline：keep，并把 baseline 更新为新分，写入 `results.tsv`
   - 否则：revert 该 commit，并在 `results.tsv` 记录一次 revert 尝试（dimension + note）

---

## Artifacts（产物）

每次 round 产生：
- `docs/reports/YYYY-MM-DD-darwin-skill-eval-<skill>-roundN.md`
- `results.tsv` 新增一行（keep 或 revert）

---

## Success Criteria

- 每个 skill 的每次尝试都遵循 ratchet：**只保留严格提升**
- `results.tsv` 可复现（commit、old/new、status、dimension、note、dry_run）
- 输出不变得更“comprehensive”，改动以边界与可执行性为中心

