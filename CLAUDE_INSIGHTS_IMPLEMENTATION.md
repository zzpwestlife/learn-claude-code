# Claude Code Insight 借鉴落地清单

基于 `/Users/admin/openSource/learn-claude-code/claude-code-insight-memory-report.html` 的深度分析。

## 1. 深度分析与最佳实践提取

### 1.1 提示词 (Prompt) 设计：语义化 Git 工作流
*   **原文引用**:
    > "Semantic Git Workflow Pattern... Always specify explicit file staging when creating multiple commits... Never use 'git add .' when creating semantic commits." (Report Lines 706-713)
*   **技术原理**:
    *   **上下文精确控制**: 通过明确指定文件路径，减少模型因上下文过大或模糊指令而产生的幻觉（如错误地将临时文件加入提交）。
    *   **原子性操作**: 强制模型将任务拆解为最小单元，便于回滚和审查。
*   **业务映射**: 当前项目包含 Go 代码、Shell 脚本和文档，混合修改频繁。报告指出曾发生 "Claude accidentally staged all files into one commit" 的事故。
*   **最小落地方案**:
    *   **文件**: `/Users/admin/openSource/learn-claude-code/CLAUDE.md`
    *   **代码**:
        ```markdown
        ## Git Workflow Rules
        - **Explicit Staging**: MUST use `git add <path>` for specific files. NEVER use `git add .`.
        - **Verification**: MUST run `git status` before committing.
        ```

### 1.2 技能 (Skill) 定义：标准化代码审查
*   **原文引用**:
    > "Custom Skills... Reusable prompts defined as markdown files that run with a single /command... 'Review the Go code changes using git diff...'" (Report Lines 615-623)
*   **技术原理**:
    *   **认知卸载 (Cognitive Offloading)**: 将复杂的 Prompt 工程固化为代码（Markdown），保证每次执行的一致性。
    *   **Token 优化**: 预定义的 Skill 可以包含精炼的上下文指令，无需用户重复输入，节省 Token。
*   **业务映射**: 报告显示 "Code Review" 是高频任务 (49 sessions)。当前项目已有 `review-code` 命令，但可进一步标准化为 Skill。
*   **最小落地方案**:
    *   **文件**: `/Users/admin/openSource/learn-claude-code/.claude/skills/review-code/SKILL.md`
    *   **代码**:
        ```markdown
        # Code Review Skill
        Run `git diff --cached` (if staged) or `git diff HEAD` (if clean).
        Analyze the Go code for:
        1. Correctness & Bugs
        2. Performance issues
        3. Idiomatic Go usage
        4. Security vulnerabilities
        Output a bulleted list of issues.
        ```

### 1.3 智能体 (Agent) 架构：跨平台脚本测试与修复
*   **原文引用**:
    > "Cross-Platform Script Testing... Test shell scripts on both macOS and Linux early... Use 'command -v' instead of 'which'..." (Report Lines 721-728)
*   **技术原理**:
    *   **环境感知 (Context Awareness)**: Agent 在执行前需先感知环境（OS, Tools），并动态调整策略。
    *   **自我修复 (Self-Healing)**: 遇到错误（如 sed 语法不通）时，自动回退或切换命令变体。
*   **业务映射**: 报告明确指出 "macOS tool compatibility issues (sed/grep)" 是主要摩擦点。
*   **最小落地方案**:
    *   **文件**: `/Users/admin/openSource/learn-claude-code/CLAUDE.md` (作为 Rule) 或 `.claude/hooks/pre-commit` (作为 Hook)
    *   **代码**:
        ```bash
        # CLAUDE.md Rule
        - **Shell Compatibility**: Check `uname -s` before using `sed`. Use `sed -i ''` for macOS, `sed -i` for Linux.
        ```

---

## 2. 落地清单 (Implementation Checklist)

| 优先级 | 任务项 | 预期收益指标 | 验证计划 |
| :--- | :--- | :--- | :--- |
| **High** | **更新 CLAUDE.md (Git/Shell 规则)** | Git 操作回滚率降低 50%<br>Shell 脚本报错率降低 80% | 1. 模拟一次多文件修改，要求 Claude 生成多个 Commit。<br>2. 检查其是否使用了 `git add .`。 |
| **High** | **创建标准 Review Skill** | Code Review 启动耗时减少 90% (仅需输入 `/review`)<br>Review 覆盖点一致性 100% | 1. 运行 `claude skill review`。<br>2. 确认其输出了预定义的 4 个维度的检查结果。 |
| **Medium** | **配置 Pre-commit Hooks (Go Vet/Fmt)** | CI 失败率降低 30%<br>代码风格统一性提升 | 1. 故意提交格式错误的代码。<br>2. 确认 Commit 被拦截并自动修复。 |
| **Low** | **探索 "自愈型 Git 历史" Agent** | Git History 清理耗时减少 70% | 1. 创建一个混乱的 Git 分支。<br>2. 尝试让 Agent 自动 Squash 和 Rebase。 |

---

## 3. 下一步行动建议

1.  **立即执行**: 将 Git 和 Shell 规则写入 `CLAUDE.md`。
2.  **立即执行**: 检查并优化现有的 `review-code` skill。
3.  **本周内**: 配置 `.claude/hooks/pre-commit` 以自动运行 `go fmt` 和 `go vet`。
