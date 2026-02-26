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

## 5. 最佳实践 (Best Practices)

| 场景 | 推荐策略 | 原因 |
| :--- | :--- | :--- |
| **特定工作流** | 手动创建 | 需精确控制 Prompt 逻辑 (如 Git 提交规范) |
| **第三方库/框架** | 社区查找 > 自动生成 | 社区版通常经过优化；无社区版则用 Skill Seekers 生成 |
| **内部私有文档** | 自动生成 | 快速将私有知识转化为 Agent 能力 |
| **调试 Skill** | 修改 `SKILL.md` | 本地文件修改即时生效，无需重装 |
