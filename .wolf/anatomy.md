# anatomy.md

> Auto-maintained by OpenWolf. Last scanned: 2026-05-21T22:00:00.420Z
> Files: 343 tracked | Anatomy hits: 0 | Misses: 0

## ./

- `.claudeignore` — Core ignores to reduce context window usage and improve performance (~79 tok)
- `.DS_Store` (~3824 tok)
- `.gitignore` — Git ignore rules (~105 tok)
- `ARCHITECTURE.md` — Project Architecture (~495 tok)
- `CLAUDE.md` — OpenWolf (~169 tok)
- `HANDOFF.md` — HANDOFF — learn-claude-code (~408 tok)
- `INTERNAL_SKILLS_EVALUATION.md` — 内部 Skill Hub 上架评估报告 (~780 tok)
- `Makefile` — Make build targets (~186 tok)
- `README.md` — Project documentation (~1302 tok)
- `skills-lock.json` (~1118 tok)
- `SuBMdg8yoorjYsxLZQEcTxtgnae.md` — 架构设计: 为什么需要 Tool Registry? (~3017 tok)

## .claude/

- `.DS_Store` (~2732 tok)
- `.ft-claude-pre-tool-use.log` (~104383 tok)
- `AGENTS.md` — ================================== (~1208 tok)
- `changelog_config.json` (~50 tok)
- `lessons.md` — Lessons (Project Memory) (~64 tok)
- `settings.json` (~874 tok)
- `settings.local.json` (~292 tok)
- `skill-usage.log` (~568 tok)
- `SOUL.md` — SOUL.md - AI Identity & Core Values (~630 tok)
- `superpowers.lock.json` (~129 tok)

## .claude/checklists/

- `mental_model_checklist.md` — 心理模型应用检查清单 (Mental Model Application Checklist) (~338 tok)

## .claude/commands/

- `archive-task.md` (~74 tok)
- `audit-skills.md` (~183 tok)
- `brainstorm.md` (~66 tok)
- `changelog-generator.md` (~226 tok)
- `commit-message-generator.md` — Commit Message Generator (~189 tok)
- `execute-plan.md` (~67 tok)
- `optimize-prompt.md` — Prompt Optimization Command (~552 tok)
- `review-code.md` — Code Review Command (~272 tok)
- `tidy-memory.md` (~66 tok)
- `write-plan.md` (~66 tok)

## .claude/constitution/

- `constitution.md` — Project Constitution (Condensed) (~1005 tok)
- `go_annex.md` — Constitution Annex: Go Language Implementation Details (~630 tok)
- `prompt_engineering_annex.md` — Prompt Engineering Standard (~179 tok)

## .claude/docs/

- `mental_model_dashboard.md` — 心理模型应用仪表盘 (Mental Model Application Dashboard) (~294 tok)

## .claude/docs/guides/

- `agent_bdd_loop.md` — Agent BDD Loop (Red-Green Agent Workflow) (~979 tok)
- `automation_meta_skills.md` — Automation & Meta-Skills Guide (~974 tok)

## .claude/docs/references/

- `mental_model_whitepaper.md` — 心理模型应用白皮书：构建认知驱动的 AI 原生架构 (~898 tok)
- `token_optimization.md` — Token Optimization & Context Management Whitepaper (~2114 tok)

## .claude/docs/references/commands/

- `commit_msg_full.md` — 核心原则 (Core Principles) (~984 tok)
- `optimize_prompt_full.md` — 核心原则 (Anthropic Best Practices) (~1009 tok)
- `review_code_full.md` — Workflow Handoff (~1103 tok)

## .claude/docs/references/skills/

- `auto_doc_full.md` — Auto-Doc Skill: Recursive Documentation Maintenance (~681 tok)
- `brainstorming_full.md` — Brainstorming Ideas Into Designs (~1503 tok)
- `condition-based-waiting.md` — Condition-Based Waiting (~875 tok)
- `defense-in-depth.md` — Defense-in-Depth Validation (~912 tok)
- `executing_plans_full.md` — Executing Plans (~999 tok)
- `finishing_branch_full.md` — Finishing a Development Branch (~1058 tok)
- `git_worktrees_full.md` — Using Git Worktrees (~1409 tok)
- `root-cause-tracing.md` — Root Cause Tracing (~1330 tok)
- `subagent_full.md` — Subagent-Driven Development (~2544 tok)
- `test-academic.md` — Academic Test: Systematic Debugging Skill (~164 tok)
- `test-pressure-1.md` — Pressure Test 1: Emergency Production Fix (~475 tok)
- `test-pressure-2.md` — Pressure Test 2: Sunk Cost + Exhaustion (~571 tok)
- `test-pressure-3.md` — Pressure Test 3: Authority + Social Pressure (~673 tok)
- `testing-anti-patterns.md` — Testing Anti-Patterns (~2056 tok)
- `writing_plans_full.md` — Writing Plans (~929 tok)

## .claude/docs/whitepapers/

- `monitoring_guide.md` — Token Monitoring Guide (~385 tok)

## .claude/hooks/

- `log-skill.sh` — Get the absolute path to the project root (parent of .claude/hooks/) (~110 tok)
- `rtk-rewrite.sh` — rtk-hook-version: 2 (~534 tok)
- `session-summary.sh` — Session End Hook: Scan for Tweet Material (~1688 tok)
- `stop-hook.sh` — Superpower Loop Stop Hook (~3034 tok)

## .claude/hooks/go/

- `format-go-code.sh` — Claude Code Hook: Auto Format Go Code (~375 tok)

## .claude/hooks/python/

- `format-python-code.sh` — Claude Code Hook: Auto Format Python Code (~222 tok)

## .claude/rules/

- `CORE_RULES.md` — CORE RULES & PROTOCOLS (Unified V1.0) (~1319 tok)
- `openwolf.md` (~313 tok)

## .claude/scripts/

- `architect.py` — Configuration (~1928 tok)
- `archive-task.sh` — Archive current plan and design documents (~320 tok)
- `audit_skills.py` — get_latest_transcript, main (~793 tok)
- `changelog_agent.py` — -*- coding: utf-8 -*- (~1211 tok)
- `check-complete.sh` — Check if all tasks in the latest plan file are complete (~797 tok)
- `claudeception-activator.sh` — Smart Skill Architect Activator (~1092 tok)
- `cleanup.sh` — Cleanup runtime artifacts script (~108 tok)
- `find_skills.py` — find_skills (~706 tok)
- `session-eval.sh` — session-eval.sh - Claude Code Session Evaluator (~1546 tok)
- `setup-superpower-loop.sh` — Superpower Loop Setup Script (~2436 tok)
- `statusline.sh` — 读取 stdin 输入 (~1088 tok)
- `superpowers-session-start` — SessionStart hook for superpowers plugin (Optimized) (~619 tok)
- `sync-superpowers.py` — Configuration (~1699 tok)
- `tidy-memory.sh` — Tidy Memory Script (~258 tok)
- `token-analyzer.py` — estimate_tokens, analyze_directory (~754 tok)

## .claude/skills/

- `.DS_Store` (~1640 tok)

## .claude/skills/brainstorming/

- `SKILL.md` — Brainstorming Ideas Into Designs (~3619 tok)

## .claude/skills/code-review/

- `SKILL.md` — Code Review Skill (~1649 tok)

## .claude/skills/code-review/assets/

- `code-reviewer-prompt.md` — Code Review Agent (~847 tok)
- `report-template.md` — CODE_REVIEW.md Template (~137 tok)

## .claude/skills/code-review/references/

- `review-checklist.md` — Review Checklist (~121 tok)

## .claude/skills/code-review/scripts/

- `get-diff.sh` (~34 tok)
- `lint-runner.py` — has_file, run, main (~195 tok)
- `metadata-checker.py` — is_text_file, scan_module_readme, scan_headers, main (~533 tok)

## .claude/skills/darwin-skill/

- `README_EN.md` — darwin.skill (~1316 tok)
- `README.md` — Project documentation (~845 tok)
- `results.tsv` (~4089 tok)
- `showcase.html` — 自主技能优化系统 (~6832 tok)
- `SKILL.md` — Darwin Skill (~2896 tok)
- `test-prompts.json` (~214 tok)

## .claude/skills/darwin-skill/assets/

- `chart-loop-en.html` — darwin.skill - Core Loop (~1876 tok)
- `chart-loop.html` — 达尔文.skill - Core Loop (~2322 tok)
- `chart-phases-en.html` — Optimization Lifecycle (~1183 tok)
- `chart-phases.html` — Optimization Lifecycle (~1167 tok)
- `chart-ratchet-en.html` — Ratchet Mechanism (~1994 tok)
- `chart-ratchet.html` — Ratchet Mechanism (~2021 tok)
- `chart-rubric-en.html` (~2107 tok)
- `chart-rubric.html` (~2067 tok)

## .claude/skills/darwin-skill/docs/

- `index.html` — 自主技能优化系统 (~6832 tok)

## .claude/skills/darwin-skill/scripts/

- `screenshot.mjs` — Darwin Skill - 高清截图脚本 (~471 tok)

## .claude/skills/darwin-skill/templates/

- `result-card-dark.html` — Darwin Skill - 暗夜成就 (~4624 tok)
- `result-card-white.html` — Darwin Skill - 我的Skill进化报告（白金版） (~2916 tok)
- `result-card.html` — Darwin Skill - 我的Skill进化报告 (~4080 tok)

## .claude/skills/design-first/

- `result-card.html` — Darwin Skill - 我的Skill进化报告 (~4095 tok)
- `SKILL.md` — 铁律 (~1629 tok)
- `test-prompts.json` (~133 tok)

## .claude/skills/dispatching-parallel-agents/

- `SKILL.md` — Dispatching Parallel Agents (~1818 tok)

## .claude/skills/executing-plans/

- `SKILL.md` — Executing Plans (~1229 tok)
- `test-prompts.json` (~110 tok)

## .claude/skills/executing-plans/assets/prompts/

- `code-quality-reviewer-prompt.md` — Code Quality Reviewer Prompt Template (~158 tok)
- `implementer-prompt.md` — Implementer Subagent Prompt Template (~723 tok)
- `spec-reviewer-prompt.md` — Spec Compliance Reviewer Prompt Template (~499 tok)

## .claude/skills/finishing-a-development-branch/

- `SKILL.md` — Finishing a Development Branch (~1934 tok)

## .claude/skills/humanizer/

- `SKILL.md` — Humanizer: Remove AI Writing Patterns (~6920 tok)

## .claude/skills/lark-doc-copywriting/

- `lark_copywriting.py` — INPUT: /tmp/doc_original.md (fetched lark doc markdown) (~1414 tok)
- `lark_to_md.py` — INPUT: Lark doc URL (argv[1]), optional output path (argv[2]) (~791 tok)
- `show_summary.py` — INPUT: /tmp/doc_diff.txt, /tmp/code_candidates.json (~242 tok)
- `SKILL.md` — lark-doc-copywriting (~2019 tok)
- `test-prompts.json` (~145 tok)

## .claude/skills/neat-freak/

- `SKILL.md` — 洁癖 — Knowledge Base Neat-Freak (~2463 tok)
- `test-prompts.json` (~364 tok)

## .claude/skills/neat-freak/references/

- `agent-paths.md` — Agent 记忆与配置路径速查 (~530 tok)
- `sync-matrix.md` — 变更影响矩阵 (~578 tok)

## .claude/skills/receiving-code-review/

- `SKILL.md` — Code Review Reception (~1722 tok)

## .claude/skills/requesting-code-review/

- `SKILL.md` — Requesting Code Review (~872 tok)

## .claude/skills/subagent-driven-development/

- `SKILL.md` — Subagent-Driven Development (~3306 tok)

## .claude/skills/systematic-debugging/

- `SKILL.md` — Systematic Debugging (~2972 tok)

## .claude/skills/test-driven-development/

- `SKILL.md` — Test-Driven Development (TDD) (~2832 tok)
- `test-prompts.json` (~102 tok)

## .claude/skills/using-git-worktrees/

- `SKILL.md` — Using Git Worktrees (~2166 tok)

## .claude/skills/using-superpowers/

- `SKILL.md` — Instruction Priority (~1575 tok)

## .claude/skills/verification-before-completion/

- `SKILL.md` — Verification Before Completion (~1356 tok)
- `test-prompts.json` (~103 tok)

## .claude/skills/writing-plans/

- `SKILL.md` — Writing Plans (~2122 tok)

## .claude/skills/writing-skills/

- `SKILL.md` — Writing Skills (~5812 tok)

## .claude/tmp/

- `session_summary.md` — Session Summary - 2026-05-21 09:23:29 (~202 tok)

## .trae/

- `.DS_Store` (~2186 tok)

## .trae/skills/

- `.DS_Store` (~1640 tok)

## .trae/specs/ai-observability-knowledge-system/

- `checklist.md` (~124 tok)
- `spec.md` — AI Observability Knowledge System Spec (~185 tok)
- `tasks.md` — Tasks (~226 tok)

## .trae/specs/create-golang-test-generator-skill/

- `checklist.md` (~74 tok)
- `spec.md` — Golang Test Generator Skill Spec (~231 tok)
- `tasks.md` — Tasks (~152 tok)

## .trae/specs/evaluate-internal-skills/

- `checklist.md` (~30 tok)
- `spec.md` — Evaluate Internal Skills for Skill Hub Spec (~158 tok)
- `tasks.md` — Tasks (~137 tok)

## .trae/specs/lean-skill-catalog/

- `checklist.md` (~24 tok)
- `spec.md` — 精简技能改造方案 Spec (~396 tok)
- `tasks.md` — Tasks (~132 tok)

## claude_plugins/gopls/

- `.lsp.json` (~76 tok)
- `CLAUDE.md` — Claude Code Configuration Entry Point (~169 tok)
- `gopls_wrapper.sh` (~149 tok)
- `plugin.json` (~32 tok)

## config/

- `manifest.json` (~513 tok)

## docs/

- `.DS_Store` (~2732 tok)
- `consolidation_report.md` — 文档整理报告 (Documentation Consolidation Report) (~401 tok)
- `README.md` — Project documentation (~275 tok)
- `zh-copywriting-guidelines.md` — 中文文案排版指北 (Chinese Copywriting Guidelines) (~435 tok)

## docs/agentic-patterns/

- `adversarial-review.md` — Adversarial Review Pattern (~800 tok)

## docs/best_practices/

- `code_review_workflow.md` — Code Review Best Practices: The Fresh-Eyes Principle (~1175 tok)
- `context_isolation.md` — Context Isolation: The "AI Flow State" Strategy (~717 tok)
- `dual_persona_workflow.md` — The Dual Persona Workflow: Builder (Opus) vs. Critic (Codex) (~657 tok)
- `review_strategy_comparison.md` — Code Review Strategy Comparison: `/new` Session vs. SubAgent (Multi-Model) (~933 tok)

## docs/course/

- `.DS_Store` (~2186 tok)

## docs/course/AI 原生开发工作流实战-Tony Bai/

- `00_introduction.md` — 从 "AI 助理" 到 "AI 同事": 我们离真正的生产力还有多远? (~1562 tok)
- `01_paradigm_evolution.md` — 我们身处的 "集成困境" (~1606 tok)
- `02_core_engine_spec_driven.md` — 软件开发中 "失落的翻译" 问题 (~1852 tok)
- `03_agent_ecosystem_claude_code.md` — 为何是 Coding Agent?—— 寻找 AI 原生开发的最佳载体 (~1762 tok)
- `04_environment_setup.md` — 第一步: 安装 "车身"—— 获取 Claude Code 客户端 (~2150 tok)
- `05_interaction_model.md` — AI 的两只手: 一种新的人机交互哲学 (~3681 tok)
- `06_context_art_part1.md` — AI Agent 的 "长期记忆": 为什么我们需要 `CLAUDE.md`? (~5774 tok)
- `07_context_art_part2.md` — 从 "工作手册" 到 "根本大法": 两种上下文的定位差异 (~1678 tok)
- `08_custom_commands.md` — 内置指令精讲: 日常提效的瑞士军刀 (~2108 tok)
- `09_security_basics_part1.md` — AI Agent 的核心风险: 信任, 一个必须解决的技术问题 (~2883 tok)
- `10_security_basics_part2.md` — Checkpointing 工作原理: 会话级的 "Git 快照" (~1870 tok)
- `11_event_driven_hooks.md` — 从 "用户调用" 到 "事件触发": 一种新的自动化哲学 (~3218 tok)
- `12_mcp_servers.md` — 超越内置工具: 为什么我们需要 MCP? (~3996 tok)
- `13_agent_skills.md` — 从 "指令" 到 "技能": 为什么说 Agent Skills 是能力涌现的关键? (~3827 tok)
- `14_subagents.md` — 多智能体势在必行: 为什么一个 "大脑" 不够用? (~3646 tok)
- `15_headless_mode.md` — 什么是 Headless 模式?—— 让 AI 成为可编程的函数 (~2683 tok)
- `16_top_level_design.md` — 为什么要先设计一个 "AI 协作框架"? (~3251 tok)
- `17_requirements_and_design.md` — 为什么我们不直接用 spec-kit ? (~3370 tok)
- `18_planning_and_tasks.md` — 回顾: 我们在 "编译三部曲" 中的位置 (~2925 tok)
- `19_coding_and_testing.md` — 回顾: 我们在 "编译三部曲" 中的位置 (~5102 tok)
- `20_collaboration_and_review.md` — 回顾: 我们在 "编译三部曲" 中的位置 (~2915 tok)
- `21_build_and_delivery.md` — 回顾: 我们在 "编译三部曲" 中的位置 (~4562 tok)
- `22_maintenance_and_refactoring.md` — 从 "新项目" 到 "遗留系统": AI 在存量代码中的新挑战 (~2630 tok)
- `23_conclusion.md` — 我们的航海图: 一次完整的思维与技能升维 (~887 tok)
- `README.md` — Project documentation (~1704 tok)

## docs/design/

- `2026-02-26-claude-config-optimization-design.md` — `.claude/` 目录 Token 效率与架构优化设计 (~805 tok)
- `2026-03-18-password-generator.md` — Design: Password Generator CLI (~302 tok)
- `mindmap-rated.md` — Learn Claude Code — 评级思维导图 (~2501 tok)
- `mindmap.md` — Learn Claude Code — 项目思维导图 (~898 tok)
- `smart-skill-architect.md` — ## 🧠 Smart Skill Architect (Auto-Evaluation) (~127 tok)

## docs/guides/

- `agent_orchestration_tools.md` — AI 编程 Agent 编排工具指南：Superset, Conductor, OpenCode 与 OpenClaw (~803 tok)
- `ai_native_workflow.md` — AI 原生开发工作流指南 (~455 tok)
- `CHROME_DEBUGGING_GUIDE.md` — Claude Code + Chrome Remote Debugging 配置指南 (~459 tok)
- `claude-code-lsp-setup.md` — Claude Code (CLI) Golang LSP 配置指南 (~792 tok)
- `claude-config-optimization-guide.md` — Claude Code 配置优化指南 (~2498 tok)
- `creating-skills.md` — Writing Skills (~5595 tok)
- `documentation-standards.md` — Documentation Context (~336 tok)
- `memory-architecture.md` — 分层记忆架构指南 (Layered Memory Architecture) (~551 tok)
- `parallel-agents.md` — Dispatching Parallel Agents (~1605 tok)
- `README.md` — Project documentation (~166 tok)
- `skill-management.md` — 技能管理指南 (Skill Management Guide) (~846 tok)
- `soul-md-guide.md` — SOUL.md：为 AI 注入灵魂的深度指南 (~1034 tok)
- `statusline_configuration.md` — Claude Code 炫酷状态行配置指南 (~1076 tok)
- `superpowers-guide.md` — Superpowers Guide (~533 tok)
- `superpowers-sync-strategy.md` — Superpowers 同步与版本管理策略 (Sync & Versioning Strategy) (~619 tok)
- `union_search_setup.md` — Union Search Skill 配置与使用指南 (~572 tok)

## docs/insight/

- `claude-code-insight-report-20260414.md` — Claude Code Insights Report (2026-04-14) (~442 tok)
- `claude-code-insight-report.html` — Claude Code Insights (~17469 tok)
- `claude-code-insight-report.md` — Claude Code 使用深度分析报告 (~833 tok)
- `memory_architecture_2026.md` — 2026 Agent 记忆工程趋势与本项目架构映射 (~593 tok)
- `report-20260317.html` — Claude Code Insights (~17191 tok)
- `report-20260327.html` — Claude Code Insights (~18957 tok)
- `report-20260414-zh.md` — Claude Code 洞察报告 (~2058 tok)
- `report-20260414.html` — Claude Code Insights (~19126 tok)

## docs/insights/

- `claude-code-insight-report-20260414.md` — Claude Code Insights Report (2026-04-14) (~442 tok)
- `claude-code-insight-report.html` — Claude Code Insights (~17469 tok)
- `claude-code-insight-report.md` — Claude Code 使用深度分析报告 (~833 tok)
- `memory_architecture_2026.md` — 2026 Agent 记忆工程趋势与本项目架构映射 (~593 tok)
- `report-20260317.html` — Claude Code Insights (~17191 tok)
- `report-20260327.html` — Claude Code Insights (~18957 tok)
- `report-20260414-zh.md` — Claude Code 洞察报告 (~2058 tok)
- `report-20260414.html` — Claude Code Insights (~19126 tok)

## docs/references/

- `README.md` — Project documentation (~210 tok)

## docs/reports/

- `2026-04-28-darwin-skill-eval-boundary-pilot-v2.md` — darwin-skill 重新评估报告（磨过的 rubric｜边界声明试点） (~609 tok)
- `2026-04-28-darwin-skill-eval-boundary-pilot.md` — darwin-skill 结构评估对比报告（边界声明试点） (~516 tok)
- `2026-04-28-darwin-skill-eval-brainstorming-round1.md` — darwin-skill Phase 2 报告（brainstorming｜Round 1） (~238 tok)
- `2026-04-28-darwin-skill-eval-brainstorming-round2.md` — darwin-skill Phase 2 报告（brainstorming｜Round 2） (~237 tok)
- `2026-04-28-darwin-skill-eval-brainstorming-round3.md` — darwin-skill Phase 3 报告（brainstorming｜Round 3：对齐微信文章实践） (~273 tok)
- `2026-04-28-darwin-skill-eval-code-review-baseline.md` — darwin-skill 评估报告（code-review｜边界声明补齐） (~282 tok)
- `2026-04-28-darwin-skill-eval-code-review-round1.md` — darwin-skill Phase 2 报告（code-review｜Round 1） (~258 tok)
- `2026-04-28-darwin-skill-eval-code-review-round2.md` — darwin-skill Phase 2 报告（code-review｜Round 2） (~223 tok)
- `2026-04-28-darwin-skill-eval-code-review-round3.md` — darwin-skill Phase 3 报告（code-review｜Round 3：对齐微信文章实践） (~276 tok)
- `2026-04-28-darwin-skill-eval-design-first-baseline.md` — darwin-skill 评估报告（design-first｜边界声明补齐） (~286 tok)
- `2026-04-28-darwin-skill-eval-design-first-round1.md` — darwin-skill Phase 2 报告（design-first｜Round 1） (~226 tok)
- `2026-04-28-darwin-skill-eval-design-first-round2.md` — darwin-skill Phase 2 报告（design-first｜Round 2） (~227 tok)
- `2026-04-28-darwin-skill-eval-design-first-round3.md` — darwin-skill Phase 3 报告（design-first｜Round 3：对齐微信文章实践） (~258 tok)
- `2026-04-28-darwin-skill-eval-executing-plans-baseline.md` — darwin-skill 评估报告（executing-plans｜边界声明补齐） (~299 tok)
- `2026-04-28-darwin-skill-eval-executing-plans-round1.md` — darwin-skill Phase 2 报告（executing-plans｜Round 1） (~255 tok)
- `2026-04-28-darwin-skill-eval-executing-plans-round2.md` — darwin-skill Phase 2 报告（executing-plans｜Round 2） (~233 tok)
- `2026-04-28-darwin-skill-eval-executing-plans-round3.md` — darwin-skill Phase 3 报告（executing-plans｜Round 3：对齐微信文章实践） (~267 tok)
- `2026-04-28-darwin-skill-eval-systematic-debugging-baseline.md` — darwin-skill 评估报告（systematic-debugging｜边界声明补齐） (~279 tok)
- `2026-04-28-darwin-skill-eval-systematic-debugging-round1.md` — darwin-skill Phase 2 报告（systematic-debugging｜Round 1） (~244 tok)
- `2026-04-28-darwin-skill-eval-systematic-debugging-round2.md` — darwin-skill Phase 2 报告（systematic-debugging｜Round 2） (~234 tok)
- `2026-04-28-darwin-skill-eval-systematic-debugging-round3.md` — darwin-skill Phase 3 报告（systematic-debugging｜Round 3：对齐微信文章实践） (~272 tok)
- `2026-04-28-darwin-skill-eval-test-driven-development-baseline.md` — darwin-skill 评估报告（test-driven-development｜边界声明补齐） (~286 tok)
- `2026-04-28-darwin-skill-eval-test-driven-development-round1.md` — darwin-skill Phase 2 报告（test-driven-development｜Round 1） (~240 tok)
- `2026-04-28-darwin-skill-eval-test-driven-development-round2.md` — darwin-skill Phase 2 报告（test-driven-development｜Round 2） (~235 tok)
- `2026-04-28-darwin-skill-eval-test-driven-development-round3.md` — darwin-skill Phase 3 报告（test-driven-development｜Round 3：对齐微信文章实践） (~263 tok)
- `2026-04-28-darwin-skill-eval-verification-before-completion-baseline.md` — darwin-skill 评估报告（verification-before-completion｜边界声明补齐） (~288 tok)
- `2026-04-28-darwin-skill-eval-verification-before-completion-round1.md` — darwin-skill Phase 2 报告（verification-before-completion｜Round 1） (~236 tok)
- `2026-04-28-darwin-skill-eval-verification-before-completion-round2.md` — darwin-skill Phase 2 报告（verification-before-completion｜Round 2） (~250 tok)
- `2026-04-28-darwin-skill-eval-verification-before-completion-round3.md` — darwin-skill Phase 3 报告（verification-before-completion｜Round 3：对齐微信文章实践） (~274 tok)
- `2026-04-28-darwin-skill-eval-writing-plans-round1.md` — darwin-skill Phase 2 报告（writing-plans｜Round 1） (~235 tok)
- `2026-04-28-darwin-skill-eval-writing-plans-round2.md` — darwin-skill Phase 2 报告（writing-plans｜Round 2） (~238 tok)
- `2026-04-28-darwin-skill-eval-writing-plans-round3.md` — darwin-skill Phase 3 报告（writing-plans｜Round 3：对齐微信文章实践） (~263 tok)
- `2026-04-28-phase2-summary.md` — Phase 2（ratchet）总览（2026-04-28） (~422 tok)
- `2026-04-28-skill-ab-eval-results-round2.md` — Skills 实测 A/B 评估结果 Round 2（2026-04-28） (~494 tok)
- `2026-04-28-skill-ab-eval-results-round3.md` — Skills 实测 A/B 评估结果 Round 3（2026-04-28） (~454 tok)
- `2026-04-28-skill-ab-eval-results-round4.md` — Skills 实测 A/B 评估结果 Round 4（2026-04-28） (~438 tok)
- `2026-04-28-skill-ab-eval-results.md` — Skills 实测 A/B 评估结果（2026-04-28） (~581 tok)
- `2026-04-29-darwin-skill-eval-neat-freak-baseline.md` — 达尔文.skill 评分报告 — neat-freak（Baseline） (~490 tok)
- `2026-04-29-darwin-skill-eval-neat-freak-round1.md` — 达尔文.skill 评分报告 — neat-freak（Round 1） (~280 tok)
- `2026-04-29-darwin-skill-eval-neat-freak-round2.md` — 达尔文.skill 评分报告 — neat-freak（Round 2） (~370 tok)
- `2026-04-29-darwin-skill-eval-neat-freak-round3.md` — 达尔文.skill 评分报告 — neat-freak（Round 3） (~189 tok)
- `2026-04-29-darwin-skill-eval-neat-freak-round4.md` — 达尔文.skill 评分报告 — neat-freak（Round 4） (~195 tok)
- `2026-04-29-darwin-skill-eval-neat-freak-round5.md` — 达尔文.skill 评分报告 — neat-freak（Round 5） (~215 tok)
- `2026-04-29-darwin-skill-eval-neat-freak-round6.md` — 达尔文.skill 评分报告 — neat-freak（Round 6） (~579 tok)
- `2026-04-29-darwin-skill-eval-neat-freak-round7.md` — 达尔文.skill 评分报告 — neat-freak（Round 7） (~179 tok)
- `2026-04-29-skill-optimization-summary.md` — 微信文章驱动 Skill 优化总览（Batch 1 + Batch 2） (~786 tok)
- `2026-05-14-claude-code-token-escape-cases.md` — Claude Code Token 脱困案例复盘 (~1301 tok)
- `2026-05-14-session-cutover-handoff-validation.md` — 2026-05-14 Session Cutover Handoff Validation (~836 tok)
- `2026-05-14-soft-token-guards-validation.md` — 2026-05-14 Soft Token Guards Validation (~590 tok)
- `2026-05-14-token-optimization-summary.md` — 2026-05-14 Token Optimization Summary (~1393 tok)
- `2026-05-19-darwin-skill-self-host-round1.md` — darwin-skill Self-Host Round 1（2026-05-19） (~910 tok)
- `2026-05-19-skill-ab-eval-execution-chain.md` — 执行链路 Skills A/B 实测结果（2026-05-19） (~1614 tok)
- `review_report.md` — Review Report for Learn Claude Code (~323 tok)

## docs/reports/templates/

- `skill-d8-eval-template.md` — Skill D8 Evaluation Template (~251 tok)

## docs/research/

- `2026-04-28-skill-audit-from-wechat.md` — Skill 审计报告（基于微信文章 + 业界实践启发式） (~508 tok)
- `2026-04-28-skill-boundary-audit.md` — Skill 边界与治理：现状调研（2026-04-28） (~431 tok)
- `2026-04-28-skill-optimization-batch2.md` — Batch2：后续 Skills 优化范围调研（2026-04-28） (~278 tok)
- `2026-04-28-wechat-skill-optimization-checklist.md` — 基于微信文章《Skill 到底能蒸馏我们的几分之几？》的 Skill 优化清单（草案） (~576 tok)
- `README.md` — Project documentation (~250 tok)
- `wechat-skill-evolver-repo-mapping.md` — 微信文章「让 Skill 自己训练自己」与 darwin-skill 仓库映射清单 (~1612 tok)

## docs/setup/

- `skill-telemetry-setup.md` — Claude Code Session Evaluator - Setup Guide (~475 tok)

## docs/skills/

- `README.md` — Project documentation (~708 tok)

## docs/specs/

- `2026-04-21--audit-skill.md` — 设计：darwin-skill 边界声明增强 (~125 tok)

## docs/superpowers/plans/

- `2026-05-14-cutover-handoff-quality.md` — Cutover Handoff Quality Implementation Plan (~2999 tok)
- `2026-05-14-installation-activation-fix.md` — Installation Activation Fix Implementation Plan (~4922 tok)
- `2026-05-14-session-cutover-handoff.md` — Session Cutover Handoff Implementation Plan (~2729 tok)
- `2026-05-14-soft-token-guards.md` — Soft Token Guards Implementation Plan (~2607 tok)
- `2026-05-14-task1-session-token-observer.md` — Task1 Session Token Observer Implementation Plan (~1170 tok)
- `2026-05-14-task2-5-token-optimization.md` — Task2-Task5 Token Optimization Implementation Plan (~869 tok)
- `2026-05-19-skill-d8-report-template.md` — Skill D8 Report Template Implementation Plan (~1550 tok)
- `2026-05-19-skill-evolver-p1-p2.md` — Skill Evolver P1-P2 Implementation Plan (~2121 tok)

## docs/superpowers/specs/

- `2026-04-28-skill-ab-eval.md` — Skills 实测 A/B 评估方案（2026-04-28） (~309 tok)
- `2026-04-28-skill-boundary-template-design.md` — Skill 边界声明模板（试点）Design (~565 tok)
- `2026-04-28-skill-optimization-plan-batch1.md` — Skill 优化方案（Batch 1）— 基于微信文章 + 业界实践 (~225 tok)
- `2026-04-28-skill-optimization-plan-brainstorming.md` — Skill 优化方案（Batch 2）：brainstorming (~432 tok)
- `2026-04-28-skill-optimization-plan-code-review.md` — Skill 优化方案（Batch 2）：code-review (~504 tok)
- `2026-04-28-skill-optimization-plan-design-first.md` — Skill 优化方案（Batch 2）：design-first (~405 tok)
- `2026-04-28-skill-optimization-plan-executing-plans.md` — Skill 优化方案（Batch 1）：executing-plans (~385 tok)
- `2026-04-28-skill-optimization-plan-systematic-debugging.md` — Skill 优化方案（Batch 2）：systematic-debugging (~496 tok)
- `2026-04-28-skill-optimization-plan-test-driven-development.md` — Skill 优化方案（Batch 1）：test-driven-development (~354 tok)
- `2026-04-28-skill-optimization-plan-verification-before-completion.md` — Skill 优化方案（Batch 1）：verification-before-completion (~361 tok)
- `2026-04-28-skill-optimization-plan-writing-plans.md` — Skill 优化方案（Batch 2）：writing-plans (~454 tok)
- `2026-04-28-skill-phase2-ratchet.md` — Phase 2（Ratchet）Skill 优化执行方案（2026-04-28） (~527 tok)
- `2026-05-14-cutover-handoff-quality-design.md` — Claude Code Cutover Handoff Quality Design (~1137 tok)
- `2026-05-14-installation-activation-fix-design.md` — Claude Code Installation Activation Fix Design (~1268 tok)
- `2026-05-14-session-cutover-handoff-design.md` — Claude Code Session Cutover Handoff Design (~1149 tok)
- `2026-05-14-soft-token-guards-design.md` — Claude Code 软治理 Token Guards Design (~1155 tok)
- `2026-05-19-skill-d8-report-template-design.md` — Skill D8 Report Template Design (~1512 tok)

## docs/一个文件让 AI Coding 效率翻倍! AGENTS.md 实践指南/

- `Claude-Code-适配落地与执行记录.md` — Claude Code 适配落地与执行记录 (~855 tok)
- `一个文件让 AI Coding 效率翻倍! AGENTS.md 实践指南.md` — 1. <span style="color: rgb(222,120,2); background-color: inherit">前言</span> (~6882 tok)

## scripts/

- `__init__.py` (~0 tok)
- `CLAUDE.md` — Claude Code Configuration Entry Point (~451 tok)
- `clean_settings_json.py` — clean_settings (~333 tok)
- `clean_user_config.sh` — Script: clean_user_config.sh (Now acts as: UNINSTALL CLAUDE CODE) (~1896 tok)
- `lint_d8_reports.py` — Lint adopted D8 report files for required template markers. (~937 tok)
- `lint_skills.py` — INPUT: Git 跟踪的 .claude/skills/*/SKILL.md 文件 (~815 tok)
- `password_gen.py` — INPUT: --length (optional, default=16) (~272 tok)
- `session_token_observer.py` — Session token observer CLI. (~1631 tok)
- `token_optimization_benchmark.py` — Benchmark prompt/token reductions for Task2-Task5 changes. (~1484 tok)

## scripts/installers/

- `install_global_statusline.sh` — 确保全局目录存在 (~1109 tok)
- `install.ps1` — Declares Write (~3020 tok)
- `install.sh` (~5005 tok)
- `patch_claude_settings.py` — INPUT: source settings path, target settings path (~807 tok)

## templates/go/

- `CLAUDE.md` — Claude Code Configuration Entry Point (~222 tok)
- `Makefile` — Make build targets (~240 tok)

## tests/

- `test_password_gen.py` — INPUT: None (tests only) (~591 tok)
- `test_session_token_observer.py` — Regression tests for session token observer CLI. (~1741 tok)

## 柜台资产业务全景图/

- `.DS_Store` (~1640 tok)
