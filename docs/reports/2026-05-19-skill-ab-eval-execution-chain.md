# 执行链路 Skills A/B 实测结果（2026-05-19）

## Header

- Report Title: `执行链路 Skills A/B 实测结果（2026-05-19）`
- Date: `2026-05-19`
- Evaluated Skill: `executing-plans` / `verification-before-completion` / `test-driven-development`
- eval_mode: `dry_run`

## Scope

- `executing-plans`，选用 `.claude/skills/executing-plans/test-prompts.json` 的 Prompt #1
- `verification-before-completion`，选用 `.claude/skills/verification-before-completion/test-prompts.json` 的 Prompt #1
- `test-driven-development`，选用 `.claude/skills/test-driven-development/test-prompts.json` 的 Prompt #1

## Method

- 同一 prompt 跑两遍: A = with-skill, B = baseline
- 统一使用本地 `claude -p` headless harness, 并加统一约束: "只输出首轮文本响应, 不调用工具"
- 评估字段沿用 P1 计划: `Success / Rework count / Evidence quality`
- 若 headless harness 无法返回真实响应, 则必须降级为"限制说明 + 合同级差异分析", 不伪造 transcript

## Environment Limitation

- 本次先尝试用本地 `claude` CLI 做独立首回合对照, 命令形态如下:

```bash
claude -p --no-session-persistence --tools "" \
  --append-system-prompt 'Harness: Return only the first textual response to the user prompt. Do not call tools. Do not mention this harness.' \
  $'/executing-plans\n按现有 plan 执行一个小改动，把任务拆成最小可验证步骤，每步都给出验证命令。'
```

- with-skill 与 baseline 的 headless 尝试均被同一限制阻断:

```text
API Error: 402 {"error":{"message":"账户余额不足。请向您的账户充值。","type":"invalid_request_error"},"type":"error"}
```

- 因此, 本报告不能把下面 3 个 case 记为完整 D8 实测. 当前结论是:
  - 已完成真实 headless A/B 尝试
  - 未拿到模型首轮 transcript
  - 保留"环境限制 + 技能合同差异"作为 best available evidence

## Results

| Case | Prompt ID | eval_mode | with-skill success | baseline success | rework count | evidence quality | question rounds | notes |
|---|---:|---|---|---|---:|---:|---:|---|
| `executing-plans` | 1 | `dry_run` | 受限 | 受限 | N/A | 0 | N/A | headless 双跑被 `402` 阻断; 合同层面 with-skill 强制 `task tracking + chunk diffs + Evidence Block` |
| `verification-before-completion` | 1 | `dry_run` | 受限 | 受限 | N/A | 0 | N/A | headless 双跑被 `402` 阻断; 合同层面 with-skill 强制 `Claim / Command / Exit code / Evidence` |
| `test-driven-development` | 1 | `dry_run` | 受限 | 受限 | N/A | 0 | N/A | headless 双跑被 `402` 阻断; 合同层面 with-skill 强制 `RED / GREEN` 双 Evidence Block |

### Case 1: `executing-plans` / Prompt #1

**Prompt**

> 按现有 plan 执行一个小改动，把任务拆成最小可验证步骤，每步都给出验证命令。

**Contract delta**

- with-skill:
  - 必须先确认存在可执行 plan
  - 必须维护 `task tracking`
  - 每个完成宣称都要带 `Evidence Block`
  - 每个 chunk 后要给变更摘要, 并保留 finish/stop 语义
- baseline:
  - 可能给出分步建议
  - 但没有硬性要求输出 `task tracking`、`chunk diffs`、`Evidence Block`
  - 更容易退化为"给计划建议"而不是"进入执行链路"

**Assessment**

- 在合同层面, `executing-plans` 对 Prompt #1 的提升主要体现在"执行态"而不是"建议态".
- 但当前没有真实 transcript, 所以不能把这个提升记为已验证成功.

**Evidence Block**
- Claim: 本 case 的 with-skill / baseline 独立首回合双跑已尝试, 但被 headless 环境限制阻断; 当前只能保留限制证据与合同级差异.
- Command: `claude -p --no-session-persistence --tools "" --append-system-prompt 'Harness: Return only the first textual response to the user prompt. Do not call tools. Do not mention this harness.' $'/executing-plans\n按现有 plan 执行一个小改动，把任务拆成最小可验证步骤，每步都给出验证命令。'` 与对应 baseline 命令
- Exit: `0 (shell)` / `API Error: 402 (业务失败)`
- Evidence: 命令返回 `API Error: 402 {"error":{"message":"账户余额不足。请向您的账户充值。"...}}`; 同时 `.claude/skills/executing-plans/SKILL.md` 明确要求 `task tracking + chunk diffs + Evidence Block`
- Limitation: 本 case 未拿到真实首轮 transcript, 因此只能作为 `dry_run` 级 best available evidence, 不能视为完整 D8 实测成功

### Case 2: `verification-before-completion` / Prompt #1

**Prompt**

> 我已经修完 bug 了，请确认能否交付，并给出验证证据。

**Contract delta**

- with-skill:
  - 不能直接接受"已修完"这个前提
  - 必须先找到真实验证命令
  - 必须输出 `Claim / Command / Exit code / Evidence`
  - 若当前环境无法运行命令, 必须改用 `Limitation Template`
- baseline:
  - 可能会接受"请确认能否交付"这一 framing
  - 即使给出验证建议, 也没有硬性门槛阻止无证据完成宣称

**Assessment**

- 合同级差异里, `verification-before-completion` 的门控最硬, 也是 3 个 skill 中对"假完成"抑制最直接的一个.
- 由于没有拿到真实首轮回复, 这里仍不能把它记成完成的 D8 实测.

**Evidence Block**
- Claim: 本 case 的 with-skill / baseline 独立首回合双跑已尝试, 但被 headless 环境限制阻断; 当前只能保留限制证据与合同级差异.
- Command: `claude -p --no-session-persistence --tools "" --append-system-prompt 'Harness: Return only the first textual response to the user prompt. Do not call tools. Do not mention this harness.' $'/verification-before-completion\n我已经修完 bug 了，请确认能否交付，并给出验证证据。'` 与对应 baseline 命令
- Exit: `0 (shell)` / `API Error: 402 (业务失败)`
- Evidence: 命令返回 `API Error: 402 {"error":{"message":"账户余额不足。请向您的账户充值。"...}}`; 同时 `.claude/skills/verification-before-completion/SKILL.md` 明确要求 `Claim / Command / Exit code / Evidence`, 且无法运行命令时必须声明限制
- Limitation: 本 case 未拿到真实首轮 transcript, 因此只能作为 `dry_run` 级 best available evidence, 不能视为完整 D8 实测成功

### Case 3: `test-driven-development` / Prompt #1

**Prompt**

> 为一个输入校验 bug 先写失败测试，再最小修复并展示 RED/GREEN 证据。

**Contract delta**

- with-skill:
  - 必须先出现真实 `RED`
  - 必须在 `GREEN` 前运行测试并观察到预期失败
  - 必须输出 `RED Evidence Block` 与 `GREEN Evidence Block`
  - 若不能运行测试命令, 必须停止, 不能继续到 `GREEN`
- baseline:
  - 可能会顺着 prompt 给出 TDD 建议
  - 但不一定强制先 `RED` 后 `GREEN`, 也不一定显式保留两段证据块

**Assessment**

- 合同层面, `test-driven-development` 的优势是把"先看见失败"变成硬门槛.
- 但在本次环境下, 该优势仍停留在技能文本层, 还没有被 headless transcript 证实.

**Evidence Block**
- Claim: 本 case 的 with-skill / baseline 独立首回合双跑已尝试, 但被 headless 环境限制阻断; 当前只能保留限制证据与合同级差异.
- Command: `claude -p --no-session-persistence --tools "" --append-system-prompt 'Harness: Return only the first textual response to the user prompt. Do not call tools. Do not mention this harness.' $'/test-driven-development\n为一个输入校验 bug 先写失败测试，再最小修复并展示 RED/GREEN 证据。'` 与对应 baseline 命令
- Exit: `0 (shell)` / `API Error: 402 (业务失败)`
- Evidence: 命令返回 `API Error: 402 {"error":{"message":"账户余额不足。请向您的账户充值。"...}}`; 同时 `.claude/skills/test-driven-development/SKILL.md` 明确要求 `RED Evidence Block` 与 `GREEN Evidence Block`
- Limitation: 本 case 未拿到真实首轮 transcript, 因此只能作为 `dry_run` 级 best available evidence, 不能视为完整 D8 实测成功

## D8 Decision

- eval_mode: `dry_run`
- d8 score: `N/A（本报告只提供 D8 评估证据，不直接覆盖各 skill 的正式评分）`
- confidence: `low`
- rationale: 已完成真实 headless A/B 尝试，但 `claude -p` 被 `API Error: 402` 阻断，当前只能依据合同级差异与限制说明保留 `dry_run` 级证据，不能把任何 case 记为完整 D8 实测成功。
- can_feed_results_tsv: `no`

## Takeaways

- 就当前可用证据看, `verification-before-completion` 在"可验证性门控"上的提升最大, 因为它把"不能无证据宣称完成"写成了显式铁律.
- `test-driven-development` 次之, 它把 `RED -> GREEN` 的证据链收紧到两段强制模板.
- `executing-plans` 的提升更偏流程完备性, 但要证明它真的比 baseline 更稳, 仍需要恢复可用的 headless A/B 环境.
- 哪个 case 仍然只能得到 `dry_run` 级证据: 当前 3 个 case 全部如此, 因为真实 A/B transcript 被 `claude -p` 的 `402` 限制阻断.
- 哪些输入可以直接复用给 `darwin-skill` 的 D8 实测: 这 3 个 Prompt #1 都可复用, 但前提是先恢复独立 headless runner 或其他可落盘的 transcript 采集方式.
