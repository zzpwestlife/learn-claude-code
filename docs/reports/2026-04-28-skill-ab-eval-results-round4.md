# Skills 实测 A/B 评估结果 Round 4（2026-04-28）

对照方式：**同一任务跑两遍**（A=with-skill，B=without-skill），在不同分支上从同一 base commit 开始实现。  
Round 4 聚焦：CI/构建链路（Makefile + 脚本编排 + 生成物一致性校验）。

**Base commit**：`344e65275f8668f32ed7ae0b9e127ce6b600ce41`

---

## Task：新增 make ci（跑测试 + 生成报表 + 校验生成物未过期）

**目标**：新增 `make ci`，包含三步：
1) 跑测试  
2) 生成报表：
   - `docs/reports/phase2-summary.generated.md`
   - `docs/reports/skill-stats.generated.md`
3) 生成后 `git diff --exit-code` 必须为 0（否则 CI 失败）

---

## A 组（with-skill / 执行计划 + 证据块 + 单测）

**分支**：`ab4-ci-with-skill`  
**Commit**：`e5d1c96`

**变更范围（多文件）**：
- `docs/superpowers/specs/2026-04-28-ab4-ci-plan.md`（计划）
- `scripts/ci.py`（编排）
- `scripts/ci_helpers.py`（通用 helper：写入去重、markdown table）
- `scripts/phase2_summary.py`（生成器）
- `scripts/skill_stats.py`（生成器）
- `scripts/unit/test_ci_helpers.py`（单测）
- `Makefile`（新增 phase2-summary/skill-stats/ci + 修复 test 指向 scripts/unit）
- 两个 `*.generated.md` 生成物（并提交）

**证据（可复现）**

Claim: `make ci` 通过，且确实运行了单测（非 0 测试）  
Command:
```bash
git checkout ab4-ci-with-skill
make ci
```
Exit code: 0  
Evidence（关键输出）：
- `Ran 2 tests ... OK`
- `python3 -m scripts.ci`

---

## B 组（without-skill / 同等功能，更少门控与证据）

**分支**：`ab4-ci-without-skill`  
**Commit**：`272755b`（含追加修复 test target）

**变更范围（多文件）**：
- `scripts/ci.py`
- `scripts/phase2_summary.py`
- `scripts/skill_stats.py`
- `Makefile`（新增 target；后续为让 CI 通过而把 test target 改到 scripts/unit）
- 两个 `*.generated.md` 生成物（并提交）
- `scripts/unit/__init__.py`（使 discover 目录可导入）

**证据（可复现）**

```bash
git checkout ab4-ci-without-skill
make ci
```

关键差异：该分支的输出为 `Ran 0 tests ... OK`（CI 绿但缺少回归保护）。

---

## Round 4 初步结论

1) 在 CI/构建链路任务中，**with-skill 更倾向于把“可验证性”做实**：不仅跑通，还能证明“真的跑了测试、生成物可重复、且不会产生未提交 diff”。  
2) without-skill 更容易出现“假绿”模式：为让流程通过，测试阶段可能退化为 0 tests，风险不可见。  

