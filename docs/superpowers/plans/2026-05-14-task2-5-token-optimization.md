# Task2-Task5 Token Optimization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 完成 Task2-Task5 的无损 token 优化落地，包括启用 Bash RTK PreToolUse Hook、压缩 claudeception-activator、将明显轻量命令切到轻量模型，并新增可复跑的 benchmark / 对比文档。

**Architecture:** 变更分成四个边界清晰的单元：Hook 配置、激活脚本、轻量命令 frontmatter、benchmark 与交付文档。验证层同时覆盖单元测试、配置断言、Hook 手工验证和基于 `git show HEAD:` 基线的对比脚本，避免把“优化”写成无法复跑的口头结论。

**Tech Stack:** Bash, Python 3.10+, `json`, `subprocess`, `tempfile`, `unittest`

---

### Task 1: 先补回归测试，锁定 Hook / 命令 / activator 行为

**Files:**
- Create: `tests/test_task2_task5_token_optimization.py`
- Modify: `.claude/settings.json`
- Modify: `.claude/scripts/claudeception-activator.sh`
- Modify: `.claude/commands/changelog-generator.md`
- Modify: `.claude/commands/audit-skills.md`
- Modify: `.claude/commands/commit-message-generator.md`

- [ ] **Step 1: 写失败测试，覆盖配置与脚本期望**
- [ ] **Step 2: 运行 `python3 -m unittest tests.test_task2_task5_token_optimization -v`，确认红灯**
- [ ] **Step 3: 仅写最小实现让测试转绿**
- [ ] **Step 4: 重新运行 `python3 -m unittest tests.test_task2_task5_token_optimization -v`，确认绿灯**

### Task 2: 启用 Bash RTK Hook 并压缩 claudeception-activator

**Files:**
- Modify: `.claude/settings.json`
- Modify: `.claude/scripts/claudeception-activator.sh`

- [ ] **Step 1: 在 `.claude/settings.json` 增加 `PreToolUse` 的 Bash matcher，接入 `.claude/hooks/rtk-rewrite.sh`**
- [ ] **Step 2: 为 `claudeception-activator.sh` 增加启停开关、重复提示缓存/去重、压缩输出**
- [ ] **Step 3: 手工验证 Hook 触发链路与 activator 去重行为**

### Task 3: 将明显轻量命令切到轻量模型并精简 prompt

**Files:**
- Modify: `.claude/commands/changelog-generator.md`
- Modify: `.claude/commands/audit-skills.md`
- Modify: `.claude/commands/commit-message-generator.md`
- Verify: `.claude/commands/review-code.md`
- Verify: `.claude/commands/optimize-prompt.md`

- [ ] **Step 1: 仅给 `changelog-generator`、`audit-skills`、`commit-message-generator` 增加或切换 `model: haiku`**
- [ ] **Step 2: 精简三者正文 prompt，保留原有职责与交互出口**
- [ ] **Step 3: 确认 `review-code` 仍为重模型，`optimize-prompt` 不降级**

### Task 4: 新增 benchmark / compare 脚本并生成总结文档

**Files:**
- Create: `scripts/token_optimization_benchmark.py`
- Create: `tests/test_token_optimization_benchmark.py`
- Create: `docs/reports/2026-05-14-token-optimization-summary.md`

- [ ] **Step 1: 写失败测试，锁定 benchmark 的 token 估算、前后对比、降幅计算行为**
- [ ] **Step 2: 实现 benchmark 脚本，基于 `git show HEAD:` 读取基线版本，对比当前工作区版本**
- [ ] **Step 3: 运行 benchmark，生成可贴入文档的前后对比结果，确认整体降幅 >= 40%**
- [ ] **Step 4: 把 benchmark 结果、回归命令、风险与长期监控建议写入总结文档**

### Task 5: 更新 specs 勾选并做全量验证

**Files:**
- Modify: `.trae/specs/reduce-token-usage/tasks.md`
- Modify: `.trae/specs/reduce-token-usage/checklist.md`
- Verify: `docs/setup/skill-telemetry-setup.md`

- [ ] **Step 1: 仅勾选本次真正完成的 Task2-Task5 条目**
- [ ] **Step 2: 运行 `make test`、`make lint-skills`、`make check`**
- [ ] **Step 3: 运行 `git diff -- .claude/settings.json .claude/scripts/claudeception-activator.sh .claude/commands/changelog-generator.md .claude/commands/audit-skills.md .claude/commands/commit-message-generator.md scripts/token_optimization_benchmark.py tests/test_task2_task5_token_optimization.py tests/test_token_optimization_benchmark.py .trae/specs/reduce-token-usage/tasks.md .trae/specs/reduce-token-usage/checklist.md docs/reports/2026-05-14-token-optimization-summary.md`**
- [ ] **Step 4: 汇总命令、结果、风险、残留验证缺口**
