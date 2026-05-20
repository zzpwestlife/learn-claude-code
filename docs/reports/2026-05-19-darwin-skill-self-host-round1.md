# darwin-skill Self-Host Round 1（2026-05-19）

## Header

- Report Title: `darwin-skill Self-Host Round 1（2026-05-19）`
- Date: `2026-05-19`
- Evaluated Skill: `darwin-skill`
- eval_mode: `dry_run`

## Scope

- Skill: `darwin-skill`
- Test prompt source: `.claude/skills/darwin-skill/test-prompts.json（本轮尚未纳入白名单，因此未在当轮真正使用）`
- Prompt IDs: `3（对应“只看历史、不继续优化”的误触发推演场景）`
- Optional round / target dimension: `Self-Host Round 1 / D3 边界条件覆盖`

## Method

- with-skill: 依据 `darwin-skill` 当前 `SKILL.md` 的规则做自优化推演，聚焦最低成本且可归因的单点改动
- baseline: 以改动前的 `darwin-skill` 文本为基线，对比同一误触发场景下是否会误入 Phase 0-3
- scoring signals: `Baseline vs Round 1` 的维度分变化、误触发降级口径是否明确、是否满足单维度可归因 ratchet
- dry_run rule: 本轮未执行独立 with-skill / baseline transcript，对误触发场景进行合同级推演与静态分析，不伪造完整实测

## Environment Limitation

- Limitations: 本次按要求只做 `P2`，且白名单不包含 `darwin-skill` 的独立 `test-prompts.json` 或 with-skill / baseline 实测资产；因此本轮只做静态分析 + 流程推演，不伪造完整实测 transcript。

## Results

### Change

- 改了什么：在 `Anti-Anchoring` 章节补 1 条“误触发降级”规则，明确当用户并未要求“优化/评分/ratchet 某个 skill”时，不进入 Phase 0-3，而是降级为普通回答，并按需请求 `SKILL.md`、测试 prompt 或 git diff。
- 为什么这是最小改动：只改 1 个章节、只补 1 条边界规则、不引入新协议，也不改动 Phase 结构与评分公式。

### Baseline
- Current score：**84.8**
- Lowest dimension：**D3 边界条件覆盖 = 6.5/10**
- Why this dimension is chosen：当前文档已有异常表，但缺少“误触发时不要进入优化循环”的显式降级口径；这是最低成本、最容易归因、且符合 `Task 3` 的单维度试点要求。
- Expected improvement：**+1.0** 分左右，来自 D3 从 `6.5 -> 7.5` 的提升；其他维度保持不变。

### Score Delta

| 维度 | 权重 | Baseline | Round 1 | 变化 | 说明 |
|---|---:|---:|---:|---:|---|
| D1 Frontmatter 质量 | 8 | 8.5 | 8.5 | 0.0 | 本轮未动 frontmatter |
| D2 工作流清晰度 | 15 | 9.0 | 9.0 | 0.0 | 主流程不变 |
| D3 边界条件覆盖 | 10 | 6.5 | 7.5 | +1.0 | 明确“误触发 -> 不进入 Phase 0-3 -> 降级请求必要输入” |
| D4 检查点设计 | 7 | 8.5 | 8.5 | 0.0 | 不变 |
| D5 指令具体性 | 15 | 8.5 | 8.5 | 0.0 | 仍以现有可执行条目为主 |
| D6 资源整合度 | 5 | 9.0 | 9.0 | 0.0 | 不变 |
| D7 整体架构 | 15 | 9.0 | 9.0 | 0.0 | 不变 |
| D8 实测表现（dry_run） | 25 | 8.5 | 8.5 | 0.0 | 未做独立实测，保持估计分 |

- Baseline：**84.8**
- New score：**85.8**
- Status：**keep**

### Case 1

**Prompt**

> 帮我解释一下 darwin-skill 最近为什么从 84.8 变成了 85.8，我现在不想继续优化，只想看历史。

**Contract Delta**

- with-skill:
  - 应识别为误触发场景
  - 不进入 Phase 0-3
  - 直接解释 `results.tsv` 与已有 round 报告
  - 必要时只请求最小输入补充，不启动新的 ratchet
- baseline:
  - 旧版本虽然已有边界约束，但缺少“只看历史时明确降级”的单句规则
  - 在误触发场景下更容易让评估者把它误解为“可以继续进入优化循环”

**Assessment**

- 本轮提升只来自误触发降级口径的明确化。
- 由于没有真实 with-skill / baseline transcript，本 case 仍然只能算 `dry_run`，不能视为完整 D8 实测成功。

**Evidence Block**
- diff summary：`SKILL.md` 仅新增 1 行，提交为 `6a899d1 optimize(darwin-skill): add mis-trigger downgrade rule`
- Claim: 本轮 self-host 的核心证据是“误触发场景下是否明确降级、不进入优化循环”，而不是新的完整 with-skill / baseline transcript。
- Command: `git diff 6a899d1^ 6a899d1 -- .claude/skills/darwin-skill/SKILL.md`、`cat .claude/skills/darwin-skill/results.tsv`
- Exit: `0（文档/记录核对成功）`
- Evidence: 推演场景为“用户只想查看 `results.tsv` 历史或解释既有评分，不要求启动优化”；改动前可能误入 Phase 0-3，改动后会直接降级为普通回答并请求必要输入；`results.tsv` 已追加 `2026-05-19	6a899d1	darwin-skill	84.8	85.8	keep	边界条件覆盖 (D3)	Add mis-trigger downgrade rule in Anti-Anchoring for self-host pilot	dry_run`
- Limitation: 本轮没有独立 with-skill / baseline transcript，也没有使用新增的 `darwin-skill/test-prompts.json` 跑真实对照，因此仍只能作为 `dry_run` 级 best available evidence

## D8 Decision

- eval_mode: `dry_run`
- d8 score: `8.5（保持估计分，不宣称已升级为 full_test）`
- confidence: `low`
- rationale: 本轮成功证明了误触发降级口径更明确，足以支撑 D3 提升与 ratchet `keep`；但 D8 仍缺少真实 with-skill / baseline transcript，因此不能把本次结果视为完整实测分。
- can_feed_results_tsv: `yes（作为 dry_run 级 ratchet 记录）`

## Takeaways

- 这次 self-host 是否成立：**成立，但仅为 dry_run 级 ratchet**。它证明 `darwin-skill` 可以在白名单范围内对自身做一次单维度、可归因、可记录的最小优化。
- 下一轮是否值得继续：**值得，但前提是先补独立实测资产并实际跑起来**。若没有 `darwin-skill` 自身的测试 prompt 与独立对照执行，后续 D8 提升仍然只能停留在估计分。
