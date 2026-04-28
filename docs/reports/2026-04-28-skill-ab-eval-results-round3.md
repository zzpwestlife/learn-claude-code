# Skills 实测 A/B 评估结果 Round 3（2026-04-28）

对照方式：**同一任务跑两遍**（A=with-skill，B=without-skill），在不同分支上从同一 base commit 开始实现。  
Round 3 聚焦：`executing-plans`（先计划再执行） + `verification-before-completion`（每步证据块）。

**Base commit**：`d2763740d52260ff9aa53bd1cce5a4121425f08f`

---

## Task（跨脚本/跨目录 + 强验证）：新增 Skill Stats 生成器

**目标**：新增 `make skill-stats`，生成 `docs/reports/skill-stats.generated.md`，表格至少包含：
- skill 名
- 文档类型（SKILL.md / skill.md / -）
- 是否有 description
- version（若存在）

---

## A 组（with-skill / 执行计划 + 证据块）

**分支**：`ab3-skill-stats-with-skill`  
**Commit**：`d2e2e77`  
**变更范围**（多文件）：
- `docs/superpowers/specs/2026-04-28-ab3-skill-stats-plan.md`（执行计划）
- `scripts/skill_stats.py`（实现）
- `scripts/unit/test_skill_stats.py` + `scripts/unit/__init__.py`（单测）
- `Makefile`（`test` 与 `skill-stats` target）
- `docs/reports/skill-stats.generated.md`（生成物）

### 证据块 1：RED→GREEN（单测）

Claim: 单测通过（且在实现前曾出现缺模块的 RED）  
Command:
```bash
git checkout ab3-skill-stats-with-skill
python3 -m unittest scripts.unit.test_skill_stats
```
Exit code: 0  
Evidence: `Ran 1 test ... OK`

### 证据块 2：集成验证（make target + 生成物）

Claim: `make skill-stats` 成功生成报表文件  
Command:
```bash
make test
make skill-stats
head -n 3 docs/reports/skill-stats.generated.md
```
Exit code: 0  
Evidence: 报表以 `| Skill | Doc | Has description | Version |` 开头

---

## B 组（without-skill / 同等功能，更少门控与证据）

**分支**：`ab3-skill-stats-without-skill`  
**Commit**：`5c717df`  
**变更范围**（多文件）：
- `scripts/skill_stats.py`
- `Makefile`
- `docs/reports/skill-stats.generated.md`

**最小验证**：
```bash
git checkout ab3-skill-stats-without-skill
make skill-stats
head -n 3 docs/reports/skill-stats.generated.md
```

---

## Round 3 初步结论

1. 在“跨目录 + 多步骤 + 需要落地验证门”的任务中，**with-skill 更容易产出可审计链路**（计划 → 单测 → make target → 生成物证据）。  
2. without-skill 能实现同等功能，但更容易缺少“回归保护（测试）”和一致的证据块；后续改动时风险更难量化。  

