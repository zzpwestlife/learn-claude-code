# Memory

> Chronological action log. Hooks and AI append to this file automatically.
> Old sessions are consolidated by the daemon weekly.

## Session: 2026-05-19 20:57

| Time | Action | File(s) | Outcome | ~Tokens |
|------|--------|---------|---------|--------|
| 21:39 | 分析微信文章并比对仓库中已有的 skill 优化实践 | docs/research, docs/reports, .claude/skills/darwin-skill | 完成文章摘要与项目借鉴性判断 | ~4500 |
| 21:46 | 已读取 AGENTS/OpenWolf/anatomy/cerebrum，确认本次任务需补研究映射文档 | .claude/AGENTS.md,.wolf/OPENWOLF.md,.wolf/anatomy.md,.wolf/cerebrum.md | 完成上下文初始化 | ~3500 |
| 21:49 | 新增微信文章与 darwin-skill 仓库映射清单，归纳已落地/未落地/建议试点 | docs/research/wechat-skill-evolver-repo-mapping.md | 文档已创建待校验 | ~1800 |
| 21:50 | 运行 make test 发现既有失败，需在交付中区分为仓库现存问题 | make test | 发现 1 error + 1 failure | ~900 |
| 21:51 | 完成文档校验与 OpenWolf 同步，记录测试现状用于最终交付 | docs/research/wechat-skill-evolver-repo-mapping.md,.wolf/* | 待输出最终总结 | ~900 |
| 21:55 | 修订 wechat-skill-evolver 映射文档：补充关系说明、统一状态标签、为试点增加优先级并保留证据路径 | docs/research/wechat-skill-evolver-repo-mapping.md | 已完成 | ~2k |
| 21:59 | 产出 Skill 自进化 P1/P2 执行计划并更新 OpenWolf 索引 | docs/superpowers/plans/2026-05-19-skill-evolver-p1-p2.md, .wolf/anatomy.md | 完成可执行短计划 | ~3200 |
| 22:11 | 产出执行链路 Skill A/B 报告，并记录 headless A/B 的 402 限制 | docs/reports/2026-05-19-skill-ab-eval-execution-chain.md, .wolf/buglog.json, .wolf/cerebrum.md | 完成 Task 2 报告并明确环境限制 | ~3200 |
| 22:11 | 运行技能文档校验 | make lint-skills | 通过，未发现本次改动引入的 skill lint 问题 | ~400 |

## Session: 2026-05-19 22:07

| Time | Action | File(s) | Outcome | ~Tokens |
|------|--------|---------|---------|--------|

## Session: 2026-05-19 22:09

| Time | Action | File(s) | Outcome | ~Tokens |
|------|--------|---------|---------|--------|

## Session: 2026-05-19 22:09

| Time | Action | File(s) | Outcome | ~Tokens |
|------|--------|---------|---------|--------|

## Session: 2026-05-19 22:09

| Time | Action | File(s) | Outcome | ~Tokens |
|------|--------|---------|---------|--------|

## Session: 2026-05-19 22:10

| Time | Action | File(s) | Outcome | ~Tokens |
|------|--------|---------|---------|--------|

## Session: 2026-05-19 22:10

| Time | Action | File(s) | Outcome | ~Tokens |
|------|--------|---------|---------|--------|
| 07:34 | 修复仓库基线失败并更新 OpenWolf 记录 | scripts/session_token_observer.py, tests/test_task2_task5_token_optimization.py, .wolf/buglog.json, .wolf/cerebrum.md | make test/check 全绿 | ~2600 |
| 07:41 | 为 darwin-skill 补独立测试资产并加回归测试 | .claude/skills/darwin-skill/test-prompts.json, tests/test_darwin_skill_assets.py, .wolf/anatomy.md | 独立测试资产已可复用到下一轮 self-host | ~1800 |
| 07:55 | 落地通用 D8 报告模板并试套执行链路 A/B 报告 | docs/reports/templates/skill-d8-eval-template.md, docs/reports/2026-05-19-skill-ab-eval-execution-chain.md, .claude/skills/darwin-skill/SKILL.md, tests/test_skill_d8_report_template.py, .wolf/anatomy.md | D8 模板已可复用，样例报告已对齐，验证全绿 | ~2300 |
| 20:28 | Resolved merge conflict in darwin-skill results.tsv and marked file as resolved | .claude/skills/darwin-skill/results.tsv | conflict cleared, no merge markers remain | ~300 |
| 20:30 | Completed D8 lint semantic validation; make check blocked by unrelated skill lint failures | scripts/lint_d8_reports.py, tests/test_lint_d8_reports.py | D8 lint green; repo check still blocked upstream | ~450 |

## Session: 2026-05-25 08:30

| Time | Action | File(s) | Outcome | ~Tokens |
|------|--------|---------|---------|--------|
| 08:48 | Created docs/talks/2026-05-25-claude-code-sharing.md | — | ~936 |
| 08:49 | Created docs/talks/demo-parallel-review-script.md | — | ~1212 |
| 08:49 | Session end: 2 writes across 2 files (2026-05-25-claude-code-sharing.md, demo-parallel-review-script.md) | 0 reads | ~2301 tok |
| 08:52 | Created docs/talks/example-skill-review-pr/SKILL.md | — | ~950 |
| 08:52 | Session end: 3 writes across 3 files (2026-05-25-claude-code-sharing.md, demo-parallel-review-script.md, SKILL.md) | 0 reads | ~3319 tok |

## Session: 2026-05-25 08:54

| Time | Action | File(s) | Outcome | ~Tokens |
|------|--------|---------|---------|--------|
| 09:13 | Edited docs/talks/2026-05-25-claude-code-sharing.md | expanded (+37 lines) | ~318 |
| 09:13 | Edited docs/talks/2026-05-25-claude-code-sharing.md | inline fix | ~9 |
| 09:13 | Edited docs/talks/2026-05-25-claude-code-sharing.md | inline fix | ~8 |
| 09:13 | Edited docs/talks/2026-05-25-claude-code-sharing.md | inline fix | ~8 |
| 09:13 | Edited docs/talks/2026-05-25-claude-code-sharing.md | expanded (+9 lines) | ~81 |
| 09:13 | Edited docs/talks/2026-05-25-claude-code-sharing.md | 4→6 lines | ~62 |
| 09:14 | Edited docs/talks/2026-05-25-claude-code-sharing.md | 5→4 lines | ~22 |
| 09:14 | Session end: 7 writes across 1 files (2026-05-25-claude-code-sharing.md) | 0 reads | ~545 tok |
| 09:23 | Created docs/talks/example-skill-review-mr/SKILL.md | — | ~1087 |
| 09:24 | Created docs/talks/demo-parallel-review-script.md | — | ~1202 |
| 09:25 | Edited docs/talks/demo-parallel-review-script.md | 6→4 lines | ~32 |
| 09:25 | Edited docs/talks/demo-parallel-review-script.md | reduced (-15 lines) | ~80 |
| 09:25 | Edited docs/talks/demo-parallel-review-script.md | reduced (-10 lines) | ~75 |
| 09:26 | Edited docs/talks/2026-05-25-claude-code-sharing.md | 23→25 lines | ~192 |
| 09:26 | Edited docs/talks/2026-05-25-claude-code-sharing.md | 9→10 lines | ~114 |
| 09:27 | Edited docs/talks/2026-05-25-claude-code-sharing.md | 5→5 lines | ~38 |
| 09:27 | Edited docs/talks/2026-05-25-claude-code-sharing.md | inline fix | ~30 |
| 09:28 | Edited docs/talks/2026-05-25-claude-code-sharing.md | reduced (-6 lines) | ~83 |
| 09:28 | Session end: 17 writes across 3 files (2026-05-25-claude-code-sharing.md, SKILL.md, demo-parallel-review-script.md) | 3 reads | ~6037 tok |
| 09:48 | Edited docs/talks/demo-parallel-review-script.md | expanded (+11 lines) | ~164 |
| 09:52 | Edited docs/talks/demo-parallel-review-script.md | modified D() | ~128 |
| 09:52 | Edited docs/talks/demo-parallel-review-script.md | 2→1 lines | ~22 |
| 09:53 | Edited docs/talks/demo-parallel-review-script.md | inline fix | ~11 |
| 09:53 | Edited docs/talks/demo-parallel-review-script.md | 3→2 lines | ~21 |
| 09:53 | Session end: 22 writes across 3 files (2026-05-25-claude-code-sharing.md, SKILL.md, demo-parallel-review-script.md) | 3 reads | ~6354 tok |
| 09:54 | Edited docs/talks/demo-parallel-review-script.md | 5→5 lines | ~62 |
| 09:54 | Session end: 23 writes across 3 files (2026-05-25-claude-code-sharing.md, SKILL.md, demo-parallel-review-script.md) | 3 reads | ~6420 tok |
| 09:55 | Session end: 23 writes across 3 files (2026-05-25-claude-code-sharing.md, SKILL.md, demo-parallel-review-script.md) | 3 reads | ~6420 tok |
| 09:56 | Edited docs/talks/example-skill-review-mr/SKILL.md | expanded (+14 lines) | ~229 |
| 09:56 | Edited docs/talks/example-skill-review-mr/SKILL.md | 6→6 lines | ~71 |
| 09:56 | Session end: 25 writes across 3 files (2026-05-25-claude-code-sharing.md, SKILL.md, demo-parallel-review-script.md) | 3 reads | ~6741 tok |
| 10:04 | Session end: 25 writes across 3 files (2026-05-25-claude-code-sharing.md, SKILL.md, demo-parallel-review-script.md) | 3 reads | ~6741 tok |
| 10:04 | Session end: 25 writes across 3 files (2026-05-25-claude-code-sharing.md, SKILL.md, demo-parallel-review-script.md) | 3 reads | ~6741 tok |
| 10:06 | Edited docs/talks/example-skill-review-mr/SKILL.md | 2→2 lines | ~56 |
| 10:06 | Session end: 26 writes across 3 files (2026-05-25-claude-code-sharing.md, SKILL.md, demo-parallel-review-script.md) | 3 reads | ~6801 tok |
| 10:11 | Edited docs/talks/example-skill-review-mr/SKILL.md | 6→8 lines | ~95 |
| 10:13 | Session end: 27 writes across 3 files (2026-05-25-claude-code-sharing.md, SKILL.md, demo-parallel-review-script.md) | 3 reads | ~6903 tok |
| 10:20 | Session end: 27 writes across 3 files (2026-05-25-claude-code-sharing.md, SKILL.md, demo-parallel-review-script.md) | 3 reads | ~6903 tok |
| 10:28 | Edited docs/talks/example-skill-review-mr/SKILL.md | 19→20 lines | ~227 |
| 10:29 | Edited docs/talks/example-skill-review-mr/SKILL.md | 6→6 lines | ~70 |
| 10:29 | Session end: 29 writes across 3 files (2026-05-25-claude-code-sharing.md, SKILL.md, demo-parallel-review-script.md) | 3 reads | ~7220 tok |
| 10:41 | Edited .gitignore | 2→6 lines | ~40 |
| 10:42 | Session end: 30 writes across 4 files (2026-05-25-claude-code-sharing.md, SKILL.md, demo-parallel-review-script.md, .gitignore) | 5 reads | ~7368 tok |

## Session: 2026-05-25 10:49

| Time | Action | File(s) | Outcome | ~Tokens |
|------|--------|---------|---------|--------|
| 10:52 | Created docs/talks/slides.html | — | ~4404 |
| 10:52 | Session end: 1 writes across 1 files (slides.html) | 1 reads | ~4719 tok |
| 10:58 | Edited docs/talks/slides.html | 10→11 lines | ~269 |
| 10:59 | Edited docs/talks/slides.html | inline fix | ~9 |
| 10:59 | Session end: 3 writes across 1 files (slides.html) | 4 reads | ~9421 tok |
| 11:02 | Created docs/talks/example-skill-review-mr/open-mr-after-note.sh | — | ~139 |
| 11:02 | Edited docs/talks/demo-parallel-review-script.md | expanded (+29 lines) | ~231 |
| 11:03 | Edited docs/talks/demo-parallel-review-script.md | 3→6 lines | ~30 |
| 11:04 | Session end: 6 writes across 3 files (slides.html, open-mr-after-note.sh, demo-parallel-review-script.md) | 6 reads | ~12000 tok |
| 11:10 | Session end: 6 writes across 3 files (slides.html, open-mr-after-note.sh, demo-parallel-review-script.md) | 6 reads | ~12000 tok |
| 11:12 | Created ../../.claude/settings.json | — | ~756 |
| 11:12 | Session end: 7 writes across 4 files (slides.html, open-mr-after-note.sh, demo-parallel-review-script.md, settings.json) | 6 reads | ~12756 tok |
| 11:13 | Created ../../.claude/settings.json | — | ~652 |
| 11:14 | Created ../../.claude/ft-settings.json | — | ~351 |
| 11:14 | Session end: 9 writes across 5 files (slides.html, open-mr-after-note.sh, demo-parallel-review-script.md, settings.json, ft-settings.json) | 7 reads | ~13759 tok |
| 11:14 | Session end: 9 writes across 5 files (slides.html, open-mr-after-note.sh, demo-parallel-review-script.md, settings.json, ft-settings.json) | 7 reads | ~13759 tok |
| 11:19 | Created ../../.claude/hooks/open-mr-after-note.sh | — | ~126 |
| 11:19 | Edited docs/talks/example-skill-review-mr/open-mr-after-note.sh | loads() → load() | ~99 |
| 11:19 | Session end: 11 writes across 5 files (slides.html, open-mr-after-note.sh, demo-parallel-review-script.md, settings.json, ft-settings.json) | 8 reads | ~14000 tok |
| 11:31 | Created docs/talks/slides.html | — | ~4728 |
| 11:31 | Session end: 12 writes across 5 files (slides.html, open-mr-after-note.sh, demo-parallel-review-script.md, settings.json, ft-settings.json) | 8 reads | ~19065 tok |
| 15:45 | Created ../../.cursor/projects/Users-admin-openSource-learn-claude-code/agent-tools/0035193c-4c85-4a9a-b395-0e5cf97cb88e.txt | — | ~26706 |
| 15:45 | Created ../../.cursor/projects/Users-admin-openSource-learn-claude-code/agent-tools/312829ab-cedc-463e-8a37-f55bb13006c3.txt | — | ~7134 |
| 15:45 | Created ../../.cursor/projects/Users-admin-openSource-learn-claude-code/agent-tools/ee27a6f2-544d-4184-a174-5e2bc9019ec7.txt | — | ~23285 |
| 15:48 | Session end: 15 writes across 8 files (slides.html, open-mr-after-note.sh, demo-parallel-review-script.md, settings.json, ft-settings.json) | 22 reads | ~90659 tok |
| 15:53 | Created docs/research/2026-05-25-wechat-reverse-prompting.md | — | ~1056 |
| 15:53 | Created docs/guides/reverse-prompting.md | — | ~411 |
| 15:53 | Created docs/plans/_templates/requirements-ack.md | — | ~196 |
| 15:53 | Created .claude/docs/references/skills/brainstorming_full.md | — | ~1767 |
| 15:53 | Created .claude/docs/references/skills/brainstorming_full.md | — | ~1817 |
| 15:53 | Created .claude/skills/design-first/SKILL.md | — | ~1880 |
| 15:53 | Created .claude/skills/design-first/SKILL.md | — | ~1956 |
| 15:54 | Created .claude/skills/systematic-debugging/SKILL.md | — | ~587 |
| 15:54 | Created .claude/skills/design-first/SKILL.md | — | ~1989 |
| 15:54 | Created docs/talks/2026-05-25-claude-code-sharing.md | — | ~1392 |
| 15:54 | Created docs/talks/2026-05-25-claude-code-sharing.md | — | ~1420 |
| 15:54 | Created docs/skills/README.md | — | ~763 |
| 15:54 | Created docs/skills/README.md | — | ~851 |
| 15:54 | Created .claude/skills/design-first/SKILL.md | — | ~2020 |
| 15:54 | Created README.md | — | ~1442 |
| 15:55 | Session end: 30 writes across 15 files (slides.html, open-mr-after-note.sh, demo-parallel-review-script.md, settings.json, ft-settings.json) | 26 reads | ~112115 tok |
| 17:25 | Session end: 30 writes across 15 files (slides.html, open-mr-after-note.sh, demo-parallel-review-script.md, settings.json, ft-settings.json) | 29 reads | ~115190 tok |
| 17:27 | Created .claude/rules/CORE_RULES.md | — | ~1607 |
| 17:27 | Created .claude/AGENTS.md | — | ~1412 |
| 17:27 | Created docs/guides/claude-code-lsp-setup.md | — | ~909 |
| 17:27 | Created docs/guides/claude-code-lsp-setup.md | — | ~870 |
| 17:28 | Created .claude/docs/references/token_optimization.md | — | ~2301 |
| 17:28 | Session end: 35 writes across 19 files (slides.html, open-mr-after-note.sh, demo-parallel-review-script.md, settings.json, ft-settings.json) | 29 reads | ~122797 tok |

## Session: 2026-05-25 17:30

| Time | Action | File(s) | Outcome | ~Tokens |
|------|--------|---------|---------|--------|

## Session: 2026-05-26 15:09

| Time | Action | File(s) | Outcome | ~Tokens |
|------|--------|---------|---------|--------|
| 15:19 | Edited .claude/settings.json | expanded (+9 lines) | ~223 |
| 15:19 | Edited .claude/AGENTS.md | expanded (+6 lines) | ~175 |
| 15:19 | Edited .claude/lessons.md | modified body() | ~195 |
| 15:20 | Session end: 3 writes across 3 files (settings.json, AGENTS.md, lessons.md) | 4 reads | ~2881 tok |
| 15:20 | Session end: 3 writes across 3 files (settings.json, AGENTS.md, lessons.md) | 4 reads | ~2881 tok |

## Session: 2026-05-26 15:40

| Time | Action | File(s) | Outcome | ~Tokens |
|------|--------|---------|---------|--------|
| 15:44 | Edited .claude/AGENTS.md | 1→2 lines | ~104 |
| 15:44 | Edited .claude/AGENTS.md | 1→2 lines | ~78 |
| 15:44 | Edited .claude/AGENTS.md | expanded (+6 lines) | ~106 |
| 15:45 | Analyzed 4 proposed additions; added GitLab MR Workflow section, Batch Edits bullet, Unverified Root Cause anti-pattern to AGENTS.md; skipped 2 duplicates | .claude/AGENTS.md | done | ~120 |
| 15:45 | Session end: 3 writes across 1 files (AGENTS.md) | 1 reads | ~549 tok |
| 15:45 | Session end: 3 writes across 1 files (AGENTS.md) | 1 reads | ~549 tok |
| 15:45 | Edited .claude/AGENTS.md | modified bodies() | ~114 |
| 15:46 | Edited .claude/AGENTS.md | 1→2 lines | ~76 |
| 15:46 | Added DEBUGGING PROTOCOL section + Pre-edit check bullet to SKILL AUTHORING CONVENTIONS | .claude/AGENTS.md | done | ~80 |
| 15:46 | Session end: 5 writes across 1 files (AGENTS.md) | 1 reads | ~752 tok |
| 15:46 | Session end: 5 writes across 1 files (AGENTS.md) | 1 reads | ~752 tok |
