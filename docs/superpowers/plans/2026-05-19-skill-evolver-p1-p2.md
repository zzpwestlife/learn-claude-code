# Skill Evolver P1-P2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把“Skill 自进化”映射清单中的 `P1/P2` 落成最小试点: 先为执行链路 skill 补齐可复现 A/B 测试, 再让 `darwin-skill` 自身完成一次受控 self-host ratchet。

**Architecture:** 本计划分两段推进。第一段先把 `executing-plans`、`verification-before-completion`、`test-driven-development` 从 `dry_run` 提升为“带 `test-prompts.json` + with-skill / baseline 对照 + 统一证据块”的真实评测输入。第二段在有了更硬的评测资产后, 仅对 `darwin-skill` 做一次单维度、可归因、可回滚的最小自优化试点, 沿用现有 `keep/revert/results.tsv` 骨架。

**Tech Stack:** Markdown, JSON, Claude Code skills, `make lint-skills`, `make test`, `make check`

---

## File Map

- Create: `.claude/skills/executing-plans/test-prompts.json`
- Create: `.claude/skills/verification-before-completion/test-prompts.json`
- Create: `.claude/skills/test-driven-development/test-prompts.json`
- Create: `docs/reports/2026-05-19-skill-ab-eval-execution-chain.md`
- Create: `docs/reports/2026-05-19-darwin-skill-self-host-round1.md`
- Modify: `.claude/skills/darwin-skill/SKILL.md`
- Modify: `.claude/skills/darwin-skill/results.tsv`
- Reference: `docs/research/wechat-skill-evolver-repo-mapping.md`
- Reference: `docs/superpowers/specs/2026-04-28-skill-phase2-ratchet.md`
- Reference: `docs/reports/2026-04-28-skill-ab-eval-results.md`

## Guardrails

- 只做 `P1/P2`; 不扩到 `P3/P4`
- `darwin-skill` 试点只允许 1 个最小改动
- `self-host ratchet` 失败时使用 `git revert` 回滚, 不用破坏性命令
- 评测证据优先采用目标技能自带的 `Evidence Block` 风格
- `make test` / `make check` 已有仓库级失败时, 需要在 handoff 里明确区分“既有失败”与“本次引入失败”

### Task 1: 为执行链路技能补齐测试输入

**Files:**
- Create: `.claude/skills/executing-plans/test-prompts.json`
- Create: `.claude/skills/verification-before-completion/test-prompts.json`
- Create: `.claude/skills/test-driven-development/test-prompts.json`
- Reference: `.claude/skills/executing-plans/SKILL.md`
- Reference: `.claude/skills/verification-before-completion/SKILL.md`
- Reference: `.claude/skills/test-driven-development/SKILL.md`

- [ ] **Step 1: 读取 3 个目标 skill 的主文档, 提取 happy path 与轻度歧义场景**

Run:

```bash
python3 - <<'PY'
from pathlib import Path
targets = [
    ".claude/skills/executing-plans/SKILL.md",
    ".claude/skills/verification-before-completion/SKILL.md",
    ".claude/skills/test-driven-development/SKILL.md",
]
for path in targets:
    text = Path(path).read_text()
    print(f"{path}: {len(text.splitlines())} lines")
PY
```

Expected: 输出 3 个 skill 文件的行数, 便于后续逐个设计 prompt。

- [ ] **Step 2: 写入 `executing-plans` 的测试集**

Write:

```json
[
  {
    "id": 1,
    "prompt": "按现有 spec 执行一个小改动, 把任务拆成最小可验证步骤, 每步都要给出验证命令。",
    "expected": "输出应体现 task tracking、chunk diffs、Evidence Block, 且不会跳过计划依赖。"
  },
  {
    "id": 2,
    "prompt": "我只有一个模糊想法, 还没有 plan, 直接帮我开工。",
    "expected": "输出应降级或停止, 明确指出缺 plan, 不应伪造执行结果。"
  },
  {
    "id": 3,
    "prompt": "只帮我 review 现有实现, 不要执行任何改动。",
    "expected": "输出应识别为误触发并降级, 不应进入执行链路。"
  }
]
```

- [ ] **Step 3: 写入 `verification-before-completion` 的测试集**

Write:

```json
[
  {
    "id": 1,
    "prompt": "我已经修完 bug 了, 请确认能否交付, 并给出验证证据。",
    "expected": "输出应要求或生成 Claim/Command/Exit/Evidence, 不接受无证据完成宣称。"
  },
  {
    "id": 2,
    "prompt": "测试命令跑不了, 但我感觉应该没问题, 直接帮我收尾。",
    "expected": "输出应停止或要求替代证据, 明确说明不能靠感觉完成。"
  },
  {
    "id": 3,
    "prompt": "只给你一个 diff 摘要, 没有命令输出, 你帮我确认已经完成。",
    "expected": "输出应指出证据不足, 不应直接放行。"
  }
]
```

- [ ] **Step 4: 写入 `test-driven-development` 的测试集**

Write:

```json
[
  {
    "id": 1,
    "prompt": "为一个输入校验 bug 先写失败测试, 再最小修复并展示 RED/GREEN 证据。",
    "expected": "输出应体现先 RED 后 GREEN, 并包含两段 Evidence Block。"
  },
  {
    "id": 2,
    "prompt": "不用写测试了, 直接把功能补上, 测试回头再说。",
    "expected": "输出应拒绝跳过 RED 阶段, 或至少明确要求先有失败测试。"
  },
  {
    "id": 3,
    "prompt": "这是一个很小的改动, 只改实现, 不必跑验证。",
    "expected": "输出应坚持最小验证闭环, 不能省略通过证据。"
  }
]
```

- [ ] **Step 5: 用 JSON 解析校验新测试集**

Run:

```bash
python3 - <<'PY'
import json
from pathlib import Path
for path in [
    ".claude/skills/executing-plans/test-prompts.json",
    ".claude/skills/verification-before-completion/test-prompts.json",
    ".claude/skills/test-driven-development/test-prompts.json",
]:
    data = json.loads(Path(path).read_text())
    assert len(data) == 3, path
    print(path, "OK", len(data))
PY
```

Expected: 3 个文件都输出 `OK 3`。

### Task 2: 跑执行链路技能的真实 A/B 基线

**Files:**
- Create: `docs/reports/2026-05-19-skill-ab-eval-execution-chain.md`
- Reference: `.claude/skills/executing-plans/test-prompts.json`
- Reference: `.claude/skills/verification-before-completion/test-prompts.json`
- Reference: `.claude/skills/test-driven-development/test-prompts.json`
- Reference: `docs/reports/2026-04-28-skill-ab-eval-results.md`

- [ ] **Step 1: 为 3 个 skill 各选 1 个最典型 prompt 做 with-skill / baseline 对照**

Use this matrix in the report:

```markdown
| Skill | Prompt ID | With-skill success | Baseline success | Rework count | Evidence quality | Notes |
|---|---:|---|---|---:|---:|---|
| executing-plans | 1 |  |  |  |  |  |
| verification-before-completion | 1 |  |  |  |  |  |
| test-driven-development | 1 |  |  |  |  |  |
```

- [ ] **Step 2: 对照执行时统一记录 Evidence Block**

Use this block for every run:

```markdown
**Evidence Block**
- Claim:
- Command:
- Exit:
- Evidence:
```

- [ ] **Step 3: 写入 A/B 报告**

Write:

```markdown
# 执行链路 Skills A/B 实测结果（2026-05-19）

## Scope
- `executing-plans`
- `verification-before-completion`
- `test-driven-development`

## Method
- 同一 prompt 跑两遍: A = with-skill, B = baseline
- 记录 Success / Rework count / Evidence quality
- 若环境限制无法完全复现, 必须明确写出限制

## Results
- [在这里填充矩阵与每个 case 的 Evidence Block]

## Takeaways
- 哪个 skill 在“可验证性”上提升最大
- 哪个 case 仍然只能得到 dry_run 级证据
- 哪些输入可以直接复用给 `darwin-skill` 的 D8 实测
```

- [ ] **Step 4: 运行技能文档校验**

Run:

```bash
make lint-skills
```

Expected: 命令成功退出; 若失败, 必须在报告中记录失败原因与对应文件。

### Task 3: 让 `darwin-skill` 自身做一次最小 self-host ratchet

**Files:**
- Modify: `.claude/skills/darwin-skill/SKILL.md`
- Modify: `.claude/skills/darwin-skill/results.tsv`
- Create: `docs/reports/2026-05-19-darwin-skill-self-host-round1.md`
- Reference: `docs/superpowers/specs/2026-04-28-skill-phase2-ratchet.md`
- Reference: `docs/research/wechat-skill-evolver-repo-mapping.md`

- [ ] **Step 1: 选择 1 个最低成本且可归因的改动维度**

Selection rule:

```markdown
- 优先 D3 或 D5
- 不改超过 1 个章节
- 不同时引入结构重写和新协议
- 改动必须能用一句话描述, 例如:
  - "补充 self-host 误触发降级条件"
  - "把 dry_run 限制说明改成可执行判据"
```

- [ ] **Step 2: 先记录 round0 基线**

Write this section into the round report:

```markdown
## Baseline
- Current score:
- Lowest dimension:
- Why this dimension is chosen:
- Expected improvement:
```

- [ ] **Step 3: 修改 `darwin-skill` 并提交 1 个最小变更**

Commit format:

```bash
git add .claude/skills/darwin-skill/SKILL.md
git commit -m "optimize(darwin-skill): <one minimal self-host change>"
```

- [ ] **Step 4: 复评分并执行 ratchet 决策**

Decision rule:

```markdown
if new_score > baseline_score:
  keep
  append keep row to `.claude/skills/darwin-skill/results.tsv`
else:
  git revert HEAD
  append revert row to `.claude/skills/darwin-skill/results.tsv`
```

- [ ] **Step 5: 写入 self-host round 报告**

Write:

```markdown
# darwin-skill Self-Host Round 1（2026-05-19）

## Change
- 改了什么:
- 为什么这是最小改动:

## Score Delta
- Baseline:
- New score:
- Status: keep / revert

## Evidence
- diff summary:
- relevant prompt / dry_run evidence:
- results.tsv appended row:

## Conclusion
- 这次 self-host 是否成立:
- 下一轮是否值得继续:
```

### Task 4: 统一验证与交接

**Files:**
- Reference: `docs/reports/2026-05-19-skill-ab-eval-execution-chain.md`
- Reference: `docs/reports/2026-05-19-darwin-skill-self-host-round1.md`
- Reference: `.claude/skills/darwin-skill/results.tsv`

- [ ] **Step 1: 运行仓库级验证**

Run:

```bash
make test
make check
```

Expected: 若命令失败, 必须区分“既有失败”还是“本次引入失败”; 不允许把历史失败包装成新问题。

- [ ] **Step 2: 生成最终 handoff**

Use this structure:

```markdown
## 完成项
- 新增了哪些 `test-prompts.json`
- 新增了哪两份报告
- `darwin-skill` 是 keep 还是 revert

## 验证
- `make lint-skills`:
- `make test`:
- `make check`:

## 风险
- 仍有哪些评测只能算半自动
- 哪些仓库级失败与本次改动无关

## 下一步
- 若 P1 成功但 P2 revert, 先补哪类输入
- 若 P2 keep, 下一轮最适合推进的维度
```

- [ ] **Step 3: 归档执行证据并准备进入 P3/P4 决策**

Run:

```bash
git status --short
```

Expected: 只看到本计划相关文件改动; 若出现无关改动, 在 handoff 中明确隔离。

---

## Self-Review

- Spec coverage: 覆盖了映射清单中的 `P1` 和 `P2`, 且没有扩到 `P3/P4`
- Placeholder scan: 所有任务都给出了目标文件、命令、模板或判定规则
- Consistency: `P1` 的产物是 `test-prompts.json + A/B 报告`, `P2` 的产物是 `darwin-skill` 单次 ratchet 报告与 `results.tsv` 记录, 两者衔接到映射清单结论
