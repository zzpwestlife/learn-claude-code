# Skill D8 Report Template Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 新增一个通用 `D8` 评测报告模板，并让现有 A/B 报告先试套一次，形成可复用且可验证的统一结构。

**Architecture:** 先用一个很小的回归测试锁住模板文件与关键字段，再创建 `docs/reports/templates/skill-d8-eval-template.md`。随后把 `2026-05-19-skill-ab-eval-execution-chain.md` 对齐到模板结构，并在 `darwin-skill` 中补一句模板入口引用。整个变更只覆盖文档与轻量测试，不引入脚本化模板消费。

**Tech Stack:** Markdown, Python `unittest`, `make lint-skills`, `make test`, `make check`

---

## File Map

- Create: `docs/reports/templates/skill-d8-eval-template.md`
- Create: `tests/test_skill_d8_report_template.py`
- Modify: `docs/reports/2026-05-19-skill-ab-eval-execution-chain.md`
- Modify: `.claude/skills/darwin-skill/SKILL.md`
- Reference: `docs/superpowers/specs/2026-05-19-skill-d8-report-template-design.md`

### Task 1: 锁定 D8 模板的最小回归测试

**Files:**
- Create: `tests/test_skill_d8_report_template.py`
- Reference: `tests/test_session_token_observer.py`
- Reference: `docs/superpowers/specs/2026-05-19-skill-d8-report-template-design.md`

- [ ] **Step 1: 写失败测试，要求模板文件存在且包含关键段落**

Write:

```python
"""Regression tests for the skill D8 report template."""

import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
TEMPLATE = REPO_ROOT / "docs/reports/templates/skill-d8-eval-template.md"


class SkillD8ReportTemplateTests(unittest.TestCase):
    def test_template_exists_and_includes_required_sections(self) -> None:
        text = TEMPLATE.read_text(encoding="utf-8")
        for marker in (
            "## Header",
            "## Scope",
            "## Method",
            "## Environment Limitation",
            "## Results",
            "## D8 Decision",
            "## Takeaways",
        ):
            self.assertIn(marker, text)

    def test_template_includes_required_table_and_evidence_fields(self) -> None:
        text = TEMPLATE.read_text(encoding="utf-8")
        for marker in (
            "| Case | Prompt ID | eval_mode | with-skill success | baseline success | rework count | evidence quality | question rounds | notes |",
            "- Claim:",
            "- Command:",
            "- Exit:",
            "- Evidence:",
            "- Limitation:",
            "- d8 score:",
            "- confidence:",
            "- rationale:",
            "- can_feed_results_tsv: yes / no",
        ):
            self.assertIn(marker, text)


if __name__ == "__main__":
    unittest.main()
```

- [ ] **Step 2: 运行测试确认 RED**

Run:

```bash
python3 -m unittest tests.test_skill_d8_report_template -v
```

Expected: `FileNotFoundError` 或断言失败，因为模板文件尚不存在。

### Task 2: 创建通用 D8 模板文件

**Files:**
- Create: `docs/reports/templates/skill-d8-eval-template.md`
- Test: `tests/test_skill_d8_report_template.py`
- Reference: `docs/reports/2026-05-19-skill-ab-eval-execution-chain.md`

- [ ] **Step 1: 写入模板文件骨架**

Write:

```md
# Skill D8 Evaluation Template

## Header
- Report Title:
- Date:
- Evaluated Skill:
- eval_mode: `full_test | dry_run`

## Scope
- Skill:
- Test prompt source:
- Prompt IDs:
- Optional round / target dimension:

## Method
- with-skill:
- baseline:
- scoring signals:
- dry_run rule:

## Environment Limitation
- Limitations: `None` / [describe constraint]

## Results

| Case | Prompt ID | eval_mode | with-skill success | baseline success | rework count | evidence quality | question rounds | notes |
|---|---:|---|---|---|---:|---:|---:|---|
| Case 1 | 1 | full_test | Y | N | 1 | 2 | 1 | with-skill 明显更稳 |

### Case 1

**Prompt**

> [paste prompt here]

**Contract Delta**

- with-skill:
- baseline:

**Assessment**

- [one-sentence judgment]

**Evidence Block**
- Claim:
- Command:
- Exit:
- Evidence:
- Limitation:

## D8 Decision
- eval_mode:
- d8 score:
- confidence:
- rationale:
- can_feed_results_tsv: yes / no

## Takeaways
- Main conclusion:
- Remaining limitations:
- Suggested next step:
```

- [ ] **Step 2: 运行测试确认 GREEN**

Run:

```bash
python3 -m unittest tests.test_skill_d8_report_template -v
```

Expected: 新增测试全部通过。

### Task 3: 用模板试套当前 A/B 报告

**Files:**
- Modify: `docs/reports/2026-05-19-skill-ab-eval-execution-chain.md`
- Reference: `docs/reports/templates/skill-d8-eval-template.md`

- [ ] **Step 1: 把现有报告重排到模板结构**

Reshape the report so it contains exactly these top-level sections:

```md
## Header
## Scope
## Method
## Environment Limitation
## Results
## D8 Decision
## Takeaways
```

Preserve the current case content, but move it under `Results` and keep one `Evidence Block` per case.

- [ ] **Step 2: 为现有 dry_run 报告补齐缺失字段**

Add these missing fields where needed:

```md
- eval_mode: `dry_run`
- question rounds: `N/A`
- confidence: `low`
- can_feed_results_tsv: `no`
```

Expected effect: 报告不再只是“结构相似”，而是严格对齐通用 D8 模板。

- [ ] **Step 3: 校验试套后的报告仍保留真实限制说明**

Check that the report still explicitly includes:

```md
- headless harness 尝试已真实执行
- transcript 未拿到
- `API Error: 402` 是当前阻断原因
- 结论不能视为完整 D8 实测成功
```

### Task 4: 为 darwin-skill 增加模板入口引用并完成验证

**Files:**
- Modify: `.claude/skills/darwin-skill/SKILL.md`
- Reference: `docs/reports/templates/skill-d8-eval-template.md`

- [ ] **Step 1: 在 `darwin-skill` 中补一句模板入口**

Add one short line near the D8 / 实测表现说明:

```md
- D8 报告默认复用 `docs/reports/templates/skill-d8-eval-template.md`；若只能做 `dry_run`，必须完整填写 Limitation 与 D8 Decision。
```

- [ ] **Step 2: 跑文档与仓库级验证**

Run:

```bash
make lint-skills
make test
make check
```

Expected: 全部通过；若失败，必须区分是否由本轮文档/测试改动引入。

- [ ] **Step 3: 生成最终 handoff**

Use this structure:

```md
## 完成项
- 新增了哪个模板文件
- 哪个测试锁住了模板字段
- 哪份报告已完成试套
- `darwin-skill` 增加了什么模板入口说明

## 验证
- `python3 -m unittest tests.test_skill_d8_report_template -v`:
- `make lint-skills`:
- `make test`:
- `make check`:

## 风险
- 当前模板仍是人工复用
- 哪些报告尚未迁移
- `dry_run` 仍可能多于 `full_test`

## 下一步
- 是否将 `2026-05-19-darwin-skill-self-host-round1.md` 也迁移到模板结构
- 是否在 2-3 份报告稳定后再考虑 lint/CI
```

---

## Self-Review

- Spec coverage: 覆盖了模板文件、试套报告、darwin-skill 入口引用、验证方式四个核心要求
- Placeholder scan: 所有任务都给出了目标文件、命令和模板骨架，没有留 TBD/TODO
- Consistency: 回归测试只锁模板存在性与关键字段，不提前引入自动解析；试套对象保持为单个 A/B 报告，未扩大到历史批量迁移
