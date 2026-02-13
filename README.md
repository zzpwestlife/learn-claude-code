# Smart Guided Workflow Template

### 🤖 智能引导工作流 (Smart Guided Workflow)

本项目已封装为 Claude Code 插件，提供了一套无缝衔接的 AI 开发工作流，通过智能引导将**提示词优化**、**方案规划**、**代码实现**、**代码审查**、**变更日志**与**提交信息**串联起来。

## 📦 安装 (Installation)

1.  克隆或下载本项目。
2.  运行安装脚本：
    ```bash
    ./install.sh
    ```
    *(安装脚本会将插件内容安装到 `~/.claude/` 目录下)*

## 🚀 使用方法

只需执行首个命令，系统将在每个阶段完成后自动引导进入下一步：

1.  **`/optimize-prompt`**: 优化原始需求提示词 -> 引导规划
2.  **`/planning-with-files:plan`**: 执行详细的任务规划与实施 -> 引导审查
3.  **`/review-code`**: 智能代码审查 -> 引导变更日志
4.  **`/changelog-generator`**: 生成 CHANGELOG.md -> 引导提交信息
5.  **`/commit-message-generator`**: 生成标准 Commit Message

**技能自我进化 (Skill Architect)**:
当你在使用任何工具时，系统会自动评估你的操作。如果你修复了一个 Bug、发现了一个更好的 Prompt 或创建了一个新工具，`Skill Architect` 会引导你将其沉淀下来。
- **Forge**: 将新能力封装为标准 Skill。
- **Refine**: 将经验（Fixes/Preferences）注入现有 Skill。
- **Stitch**: 自动更新 Skill 文档，让工具越用越聪明。
