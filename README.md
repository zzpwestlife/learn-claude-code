# FlowState (Zero-Friction Workflow)

### 🌊 FlowState: Keep Your Flow Unbroken

**FlowState** 是一个 Claude Code 插件，致力于打造**零摩擦 (Zero-Friction)** 的 AI 开发工作流。它通过智能引导将**提示词优化**、**方案规划**、**代码实现**、**代码审查**、**变更日志**与**提交信息**无缝串联，让开发过程像水一样自然流动。

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

## 💧 设计哲学：像水一样流动 (Zero-Friction Flow)

我们的核心目标是**尽量减少用户操作和输入**，打造极致的**丝滑**体验。整个工作流设计如同**多米诺骨牌**，一触即发，环环相扣。

-   **零摩擦 (Zero Friction)**: 系统会自动预判你的下一步需求，并自动填充命令。
-   **Tab 键驱动 (Tab-to-Execute)**: 你不需要手动输入复杂的指令，只需按下 `Tab` 键确认，流程就会自动向下流动。
-   **把控权 (Control in Flow)**: 在保持流畅的同时，我们在关键节点（如规划完成、阶段性执行结束）设置了“呼吸点”。系统会暂停并交还控制权，让你既能享受自动化的便利，又能随时进行人工干预。

工作流应该像水一样流畅，让你的思维不再被繁琐的命令打断。

**技能自我进化 (Skill Architect)**:
当你在使用任何工具时，系统会自动评估你的操作。如果你修复了一个 Bug、发现了一个更好的 Prompt 或创建了一个新工具，`Skill Architect` 会引导你将其沉淀下来。
- **Forge**: 将新能力封装为标准 Skill。
- **Refine**: 将经验（Fixes/Preferences）注入现有 Skill。
- **Stitch**: 自动更新 Skill 文档，让工具越用越聪明。
