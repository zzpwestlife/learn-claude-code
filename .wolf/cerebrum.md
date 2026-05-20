# Cerebrum

> OpenWolf's learning memory. Updated automatically as the AI learns from interactions.
> Do not edit manually unless correcting an error.
> Last updated: 2026-05-19

## User Preferences

<!-- How the user likes things done. Code style, tools, patterns, communication. -->
- 研究类交付默认使用中文，并在回执中同时给出修改文件与要点摘要。
- 研究类映射文档应显式写清“关系说明”，区分相近来源或阶段；状态标签统一用“已具备/部分具备/缺失”，建议试点需标注优先顺序，且每项保留证据路径。

## Key Learnings

- **Project:** learn-claude-code
- **Description:** **Learn Claude Code** 是一个标准化的 Claude Code 配置套件，旨在帮助开发者快速将最佳实践集成到自己的项目中。本版本基于 [Obra Superpowers](https://github.com/obra/superpowers)，经过精简重构，专注于 **Golang** 开发环境的优化。
- `make check` 目前先跑 `scripts/lint_skills.py`；只要工作区里新增的 skill 缺 `frontmatter.version`、`Reusable Interface (R)` 或 `Anti-Anchoring/反锚定`，就会在进入测试前直接失败。
- `scripts/` 下的 Python CLI 需要兼容仓库默认 `python3`（当前是 Python 3.9）；如果要写 `str | Path` 这类 3.10+ 注解，需配合 `from __future__ import annotations` 或改用 `typing.Union`。
- `rtk-rewrite.sh` 的设计是“缺少 `rtk` 时静默透传”；相关测试不能假设宿主环境已安装 `rtk`，应在测试里注入 fake 可执行文件来稳定复现 rewrite 行为。
- 研究映射类文档放在 `docs/research/` 时，适合用“条目 + 证据路径 + 状态标签”格式，把仓库现状与外部方法论做显式对照。
- 执行链路 Skill 的 A/B 评估若依赖本地 `claude -p` headless runner，需先验证 Claude API 可用；若出现 `402 账户余额不足`，报告必须降级为“限制说明 + 合同级差异分析”。

## Do-Not-Repeat

<!-- Mistakes made and corrected. Each entry prevents the same mistake recurring. -->
<!-- Format: [YYYY-MM-DD] Description of what went wrong and what to do instead. -->
- [2026-05-20] 处理 Git merge conflict 时，清掉 `<<<<<<< / ======= / >>>>>>>` 还不够；必须再 `git add` 该文件，`UU` 才会变成已解决状态。
- [2026-05-20] 不要把 Python 3.10 的运行时类型语法直接放进 `scripts/` CLI；先确认项目实际 `python3` 版本，必要时用延迟注解。
- [2026-05-20] 不要让测试隐式依赖宿主机安装的可选工具；对于 `rtk` 这类二进制依赖，用临时 fake binary 固定测试前提。
- [2026-05-19] 做 Skill A/B 实测前，先验证本地 `claude -p` headless runner 可用；若 API 余额不足，不要继续伪造 with-skill / baseline transcript，必须明确写成环境限制。

## Decision Log

<!-- Significant technical decisions with rationale. Why X was chosen over Y. -->
