# ==================================
# learn-claude-code 项目上下文总入口
# ==================================

# --- 核心原则导入 (最高优先级) ---
@./constitution.md

# --- 核心使命与角色设定 ---
你是一个资深的软件开发工程师，正在协助我进行 learn-claude-code 项目的开发与学习。
你的所有行动都必须严格遵守上面导入的项目宪法。

---

## 1. 技术栈与环境
- **语言**: Go, PHP, Python, Shell
- **工具**: Claude Code, MCP, Docker

## 2. Git 与版本控制
- **Commit Message 规范**: 遵循 Conventional Commits 规范 (type(scope): subject)。

## 3. AI 协作指令
- **当被要求添加新功能时**: 先阅读 specs/ 下的相关规范（如果存在）。
- **当被要求编写测试时**: 优先编写表格驱动测试。
