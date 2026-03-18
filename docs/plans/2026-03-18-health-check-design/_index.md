# Health Check 工具设计文档

<!-- INPUT: Brainstorming 拷问结论 + 3 个子 Agent 研究结果 -->
<!-- OUTPUT: 完整设计文档供 writing-plans 阶段消费 -->
<!-- POS: docs/plans/2026-03-18-health-check-design/_index.md -->

## Context

本工具是 `learn-claude-code` 套件的诊断入口，帮助开发者在新建或排查问题时快速验证本地 Claude Code 开发环境的完整性与可用性。

类比：`brew doctor` / `rustup check` 的 doctor-style 检查工具。

## Requirements

### 功能需求

| ID | 需求描述 |
|----|----------|
| F1 | 检查 Claude CLI 可用性（`claude --version`，最低版本约束可配置） |
| F2 | 验证 API Key 有效性（ping `api.anthropic.com`，不输出明文 Key，显示掩码） |
| F3 | 检查依赖工具链（`node`, `python3`, `git` 是否在 PATH 且版本合规） |
| F4 | 验证项目配置完整性（`.claude/` 目录结构、`settings.json`、`AGENTS.md` 等核心文件存在） |
| F5 | 探测 MCP 服务可达性（读取 `settings.json` 的 `mcpServers`，TCP/HTTP 探测） |
| F6 | Hooks 语法检查（`bash --norc -n <script>`，同时验证可执行权限） |
| F7 | Skills 完整性验证（frontmatter 包含必填字段 `name`, `description`） |
| F8 | 半自动修复：TUI 确认后执行修复命令（`chmod +x`, `mkdir -p` 等） |
| F9 | 全局汇总行：`Result: N Passed, N Warnings, N Failed` + 退出码规范 |

### 非功能需求

- 单文件 < 200 行（主文件 + checker 插件各自独立，每个 < 200 行）
- 零额外依赖（仅 Python 3 标准库）
- 跨平台：macOS (BSD) & Linux (GNU) 均支持
- 超时：每个外部调用 `timeout=10s`，避免阻塞

## Rationale

**为什么选择插件式 Plugin Registry？**
- 遵循开闭原则：添加新检查项只需新增 Checker 类，不修改主框架
- 与现有 `.claude/scripts/` 的过程式轻量风格融合，无过度抽象
- 每个 Checker 文件 < 200 行，满足 CORE_RULES 约束

**为什么是 Terminal 纤性输出而非全屏 TUI？**
- 输出可重定向（CI 友好），不依赖终端能力
- 与 `brew doctor` 等开发者熟悉工具保持认知一致

## Detailed Design

### 文件布局

```
.claude/
├── scripts/
│   ├── health_check.py           # 主入口：Registry + 输出格式化
│   └── checkers/
│       ├── __init__.py
│       ├── base.py               # BaseChecker + CheckResult dataclass
│       ├── claude_cli.py         # F1
│       ├── api_key.py            # F2
│       ├── deps.py               # F3
│       ├── project_config.py     # F4
│       ├── mcp.py                # F5
│       ├── hooks.py              # F6
│       └── skills.py             # F7
└── commands/
    └── health-check.md           # /health-check 命令注册
```

### CheckResult 数据模型

```python
@dataclass
class CheckResult:
    item: str      # 检查项名称（显示用）
    status: str    # "PASS" | "FAIL" | "WARN"
    message: str   # 简短描述
    fix_cmd: str   # 修复命令（空字符串表示无自动修复）
    fix_desc: str  # 修复描述（TUI 确认时展示）
```

### 输出格式

```
🔍 Claude Code Health Check
══════════════════════════════
✅  Claude CLI        claude 1.2.3 (≥ 1.0 required)
✅  API Key           Authenticated (sk-an...xxxx)
⚠️  Node.js           v16.20 (recommend ≥ 18)
❌  MCP Services      anthropic-mcp: connection refused
✅  Project Config    All required files present
✅  Hooks             3 scripts, all valid
❌  Skills            2 files missing 'description' field
══════════════════════════════
Result: 4 Passed, 1 Warning, 2 Failed

Would you like to auto-fix issues? [Y/n]
```

### 退出码规范

| 退出码 | 含义 | 触发条件 |
|--------|------|----------|
| `0` | 全部通过 | 只有 PASS，无 WARN 无 FAIL |
| `1` | 存在警告 | 有 WARN，无 FAIL |
| `2` | 存在致命错误 | 有任意 FAIL |

### 命令注册 (`.claude/commands/health-check.md`)

```markdown
---
description: 运行全量环境健康检查 (CLI、API、依赖、配置、MCP、Hooks、Skills)
allowed-tools: [Bash]
---

运行健康检查工具并展示结果：

!python3 .claude/scripts/health_check.py "$@"
```

## Design Documents

- [BDD Specifications](./bdd-specs.md) - 行为场景与测试策略
- [Architecture](./architecture.md) - 系统架构与组件细节
- [Best Practices](./best-practices.md) - 安全、性能与代码质量指引
