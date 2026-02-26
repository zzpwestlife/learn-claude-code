
### 🧠 Smart Skill Architect (Auto-Evaluation)

本项目集成了智能技能架构师 (Smart Skill Architect)，无需手动干预即可自动评估技能进化机会。

**工作原理 (Context-Aware Logic)**:
系统通过 Hook 脚本 (`.claude/hooks/claudeception-activator.sh`) 实时监测项目上下文，当检测到以下事件时自动触发：
1.  **任务完成**: `CHANGELOG.md` 在最近 5 分钟内被更新。
2.  **计划达成**: `docs/plans/` 下的最新计划全部勾选完成且最近被修改。
3.  **审查结束**: `review_report.md` 生成。

**触发效果**:
当满足条件时，系统会输出 "SKILL ARCHITECT: EVOLUTION CHECK" 提示，引导您将新获得的知识固化为 Skill。

**日志记录**:
所有评估决策均记录在 `.claude/logs/activator.log`。
