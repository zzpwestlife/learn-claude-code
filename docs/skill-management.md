# 技能管理指南 (Skill Management Guide)

本文档定义了本项目的 Skill 管理策略，旨在利用 Claude Code 的扩展能力，高效构建和管理自定义技能。

## 1. 技能概览

Skill 是 Agent 的扩展能力单元，本质上是结构化的 Prompt 和上下文。我们采用三种方式管理技能：

| 方式 | 适用场景 | 工具 | 典型例子 |
| :--- | :--- | :--- | :--- |
| **社区技能** | 通用需求 | `find-skills` / `npx` | React 最佳实践、PR Review |
| **手动创建** | 简单逻辑、特定流程 | `skill-creator` / 手写 | 生成 Commit Message、代码风格检查 |
| **自动生成** | 复杂文档、知识库 | `skill-seekers` | 内部 API 文档、特定框架文档 |

> **注意**: 技能目录位置取决于您的运行环境：
> - **Claude Code CLI**: `.claude/skills/` (本项目默认)

---

## 2. 查找与安装 (Discovery & Installation)

对于通用功能，优先查找社区已有方案。

### 查找
- **CLI**: `npx skills find <关键词>` (如 `react`, `testing`)
- **Web**: 访问 [skills.sh](https://skills.sh/)

### 安装
```bash
npx skills add <package_name>
# 示例: npx skills add vercel-labs/agent-skills@vercel-react-best-practices
```

---

## 3. 手动创建 (Manual Creation)

适用于逻辑简单、依赖 Prompt 工程的技能。

**基本结构**:
```text
.claude/skills/ (或 .trae/skills/)
└── <skill-name>/
    └── SKILL.md
```

**SKILL.md 模板**:
```markdown
---
name: "my-skill"
description: "简短描述。必须包含触发条件 (Invoke when...)"
---

# My Skill Title

这里编写详细的 Prompt 指令...
```

**快速创建**:
直接告诉 Agent: "帮我创建一个[功能]的 skill"，Agent 会调用 `skill-creator` 自动生成。

---

## 4. 自动化生成 (Automated Generation)

对于**知识密集型**场景（如几百页的文档），使用 `skill-seekers` 工具自动转换。

### 4.1 工具简介
[Skill Seekers](https://github.com/yusufkaraaslan/Skill_Seekers) 是一个"自动化工厂"，能将文档网站、GitHub 仓库、PDF 转换为结构化的 Skill 数据。

### 4.2 安装
由于系统 Python 环境限制，推荐使用 `pipx` 或虚拟环境安装：

```bash
# 方式 1: 使用 pipx (推荐)
pipx install skill-seekers

# 方式 2: 虚拟环境
python3 -m venv .venv
source .venv/bin/activate
pip install skill-seekers
```

### 4.3 使用流程
1.  **抓取 (Ingest)**:
    ```bash
    # 抓取在线文档
    skill-seekers create https://docs.react.dev/
    
    # 或抓取 GitHub 仓库
    skill-seekers create facebook/react
    ```

2.  **打包 (Package)**:
    ```bash
    # 导出为 Claude 格式
    skill-seekers package output/react --target claude
    ```

3.  **安装**:
    将生成的 ZIP 解压或文件夹移动到 `.claude/skills/` (或 `.trae/skills/`) 目录。

---

## 5. 最佳实践 (Usage Best Practices)

| 场景 | 推荐策略 | 原因 |
| :--- | :--- | :--- |
| **特定工作流** | 手动创建 | 需精确控制 Prompt 逻辑 (如 Git 提交规范) |
| **第三方库/框架** | 社区查找 > 自动生成 | 社区版通常经过优化；无社区版则用 Skill Seekers 生成 |
| **内部私有文档** | 自动生成 | 快速将私有知识转化为 Agent 能力 |
| **调试 Skill** | 修改 `SKILL.md` | 本地文件修改即时生效，无需重装 |

---

## 6. 技能编写规范 (Skill Authoring Guidelines)

为了保持 Context Window 的精简并提高 Agent 的执行效率，请遵循以下规范编写 Skill。

### 6.1 目录结构 (Directory Structure)
采用标准化的目录结构，将逻辑、知识与资源分离：

```text
skill-name/
├── SKILL.md              # 核心逻辑与导航 (Brain)
├── scripts/              # 可执行脚本 (Python/Bash/Node)，用于处理复杂逻辑
├── references/           # 知识上下文 (API Docs, Cheatsheets)，仅包含必要的知识
└── assets/               # 静态资源 (Templates, JSON Schemas)，用于输出生成
```

### 6.2 Frontmatter 优化
`SKILL.md` 的头部元数据是 Agent 路由的关键。务必包含 **Negative Triggers**（负面触发条件），以避免误触发。

```yaml
---
name: "review-code"
description: "在用户请求代码审查时触发。读取 Git 差异并输出报告。Do not use for simple syntax fixes."
---
```

### 6.3 渐进式披露 (Progressive Disclosure)
不要在 `SKILL.md` 中堆砌所有内容。使用**显式指令**引导 Agent 按需读取文件，而不是让 Agent 一次性加载所有上下文。

*   **Bad**: 在 `SKILL.md` 中直接包含 200 行的 JSON 模板。
*   **Good**: "Step 1: Read `assets/report-template.json` to get the output format."

### 6.4 确定性执行 (Deterministic Execution)
对于复杂的逻辑（如解析 Git Diff、查询数据库），优先编写 `scripts/` 下的 Python 或 Bash 脚本，而不是让 LLM 靠 Prompt 去“猜”或“模拟”执行。

*   **Rule**: 如果逻辑包含多步判断或需精确解析，必须写脚本。
*   **Benefits**: 脚本执行结果确定，且不消耗上下文 Tokens。
