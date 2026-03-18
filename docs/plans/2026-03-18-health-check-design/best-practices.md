# Best Practices: Claude Code Health Check

<!-- INPUT: 子 Agent 3 研究结果 -->
<!-- OUTPUT: 安全、性能与代码质量指引 -->
<!-- POS: docs/plans/2026-03-18-health-check-design/best-practices.md -->

## 1. API Key 安全探测

通过最小化 API 调用（`GET /v1/models`）验证有效性。

- **严禁** 打印完整密钥，仅显示掩码：`sk-an...xxxx`（前6位 + 后4位）
- 通过 HTTP 状态码（200/401/403）判定状态
- Key 不得写入任何日志文件或 stdout

```python
masked = key[:6] + "..." + key[-4:]  # 安全显示格式
```

## 2. 进程超时控制

所有 `subprocess.run()` 调用必须显式设置 `timeout`。

```python
try:
    result = subprocess.run(cmd, capture_output=True, timeout=10)
except subprocess.TimeoutExpired:
    return CheckResult(item=self.name, status="WARN",
                       message="timeout after 10s")
```

建议值：CLI 检查 5s，网络探测（API/MCP）10s。

## 3. 退出码规范

| 退出码 | 含义 | 场景 |
|--------|------|------|
| `0` | 全部通过（仅 PASS，无 WARN/FAIL） | CI 绿灯 |
| `1` | 仅有警告，无致命错误 | 提示优化 |
| `2` | 存在 FAIL | CI 红灯，阻断流程 |

## 4. 颜色与终端感知

```python
USE_COLOR = sys.stdout.isatty() and os.environ.get("NO_COLOR") is None
```

非交互式环境（管道、CI）自动退化为纯文本 `[PASS]`/`[FAIL]`/`[WARN]`。

## 5. 跨平台命令探测

优先使用 `shutil.which()` 替代 shell 的 `which` 或 `command -v`：

```python
import shutil
if shutil.which("node") is None:
    # node 不在 PATH
```

自动处理 macOS (BSD) 与 Linux (GNU) 差异，也适用于 Windows。

## 6. 文件权限校验

使用 `os.access()` 检验 Hook 脚本执行权限：

```python
import os
if not os.access(hook_path, os.X_OK):
    return CheckResult(
        item="Hooks", status="WARN",
        message=f"{hook_path.name}: not executable",
        fix_cmd=f"chmod +x {hook_path}",
        fix_desc="Grant execute permission to hook script"
    )
```

## 7. YAGNI 约束

- 不引入第三方库（`requests`、`rich` 等）
- 不实现配置文件（检查项硬编码在 Registry 中）
- 不实现并发（顺序执行，保持输出可读性）
- 不实现 watch 模式（单次执行，保持简单）
