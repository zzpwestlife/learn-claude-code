# Architecture: Claude Code Health Check

<!-- INPUT: 子 Agent 1 架构研究结果 -->
<!-- OUTPUT: 系统架构与组件设计细节 -->
<!-- POS: docs/plans/2026-03-18-health-check-design/architecture.md -->

## System Overview

```
/health-check command
        │
        ▼
.claude/commands/health-check.md   (命令注册)
        │  invokes
        ▼
.claude/scripts/health_check.py    (主入口: Registry + 输出 + 修复 TUI)
        │  iterates
        ▼
.claude/scripts/checkers/          (插件目录)
├── base.py        BaseChecker, CheckResult
├── claude_cli.py  F1: CLI 版本
├── api_key.py     F2: API Key 验证
├── deps.py        F3: 工具链检查
├── project_config.py  F4: 配置完整性
├── mcp.py         F5: MCP 可达性
├── hooks.py       F6: Hooks 语法
└── skills.py      F7: Skills 完整性
```

## Component Design

### BaseChecker (base.py)

```python
# INPUT: 无
# OUTPUT: CheckResult dataclass
# POS: .claude/scripts/checkers/base.py

from dataclasses import dataclass, field
from abc import ABC, abstractmethod

@dataclass
class CheckResult:
    item: str
    status: str        # "PASS" | "FAIL" | "WARN"
    message: str
    fix_cmd: str = ""
    fix_desc: str = ""

class BaseChecker(ABC):
    name: str = ""

    @abstractmethod
    def run(self) -> CheckResult: ...
```

### health_check.py (主入口)

职责：
1. 实例化并注册所有 Checker
2. 顺序执行 `checker.run()`，实时打印结果
3. 执行后汇总，展示修复 TUI（`input("Fix? [Y/n]")`）
4. 执行用户确认的修复命令（`subprocess.run`）
5. 设置退出码（0/1/2）

关键约束：
- `subprocess.run(..., timeout=10)` 包裹所有外部调用
- `sys.stdout.isatty()` + `NO_COLOR` 环境变量控制颜色

### Checker 插件规范

每个 Checker：
- 文件 < 200 行
- 顶部 3 行 metadata header (INPUT/OUTPUT/POS)
- 继承 `BaseChecker`，实现 `run() -> CheckResult`
- 不直接调用 `print()`，所有 IO 通过返回值传递

## Plugin Registry Pattern

```python
# health_check.py 中的 registry 初始化
CHECKERS = [
    ClaudeCLIChecker(),
    ApiKeyChecker(),
    DepsChecker(),
    ProjectConfigChecker(),
    MCPChecker(),
    HooksChecker(),
    SkillsChecker(),
]
```

添加新检查项：只需创建新 Checker 类并追加到 `CHECKERS` 列表。

## 颜色与格式化

```python
STATUS_ICONS = {
    "PASS": "✅ ",
    "FAIL": "❌ ",
    "WARN": "⚠️  ",
}
# 非 tty 环境或 NO_COLOR 设置时退化为纯文本: [PASS]/[FAIL]/[WARN]
```

## 文件 Header 规范（遵循 CORE_RULES）

每个 `.py` 文件第 1-3 行：

```python
# INPUT: <调用该模块的来源/参数>
# OUTPUT: <返回值或副作用>
# POS: <文件路径相对于仓库根>
```
