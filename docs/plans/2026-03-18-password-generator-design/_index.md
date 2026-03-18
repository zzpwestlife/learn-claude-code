# 密码生成器设计文档

**日期**: 2026-03-18
**状态**: 设计完成，待实现

---

## Context（背景）

用户需要一个 Python CLI 密码生成器工具，用于在终端快速生成安全密码。项目技术栈包含 Python 3.10+，要求零外部依赖，遵循项目 YAGNI 与简洁性原则。

---

## Requirements（需求）

### 功能需求

1. 使用 `secrets` 模块生成密码学安全的随机密码
2. 支持可开关的字符集：大写字母、小写字母、数字、特殊字符
3. 支持 `--length` 参数指定密码长度（默认 16，最小 4）
4. 每次执行输出单个密码到 stdout
5. 零第三方依赖（仅用 Python 标准库：`secrets`, `argparse`, `string`）

### 非功能需求

- 单文件，代码 < 200 行，函数 < 20 行
- 强制 3 行文件头（INPUT / OUTPUT / POS）
- 密码中每个启用的字符集至少出现一个字符
- 全部字符集禁用时，以非零状态码退出并输出明确错误信息
- 密码仅输出到 stdout，不写入任何临时文件

---

## CLI Interface Specification（接口规格）

```
usage: passgen.py [-h] [-l LENGTH] [--no-upper] [--no-lower] [--no-digits] [--no-special]

Secure Password Generator

options:
  -h, --help            show this help message and exit
  -l, --length LENGTH   Password length (default: 16, min: 4)
  --no-upper            Disable uppercase letters (A-Z)
  --no-lower            Disable lowercase letters (a-z)
  --no-digits           Disable numeric digits (0-9)
  --no-special          Disable special characters (!@#$%^&*()...)
```

**示例**:

```bash
# 默认生成 16 位包含所有字符集的密码
python scripts/passgen.py

# 生成 32 位不含特殊字符的密码
python scripts/passgen.py --length 32 --no-special

# 仅数字密码（PIN 场景）
python scripts/passgen.py --length 8 --no-upper --no-lower --no-special
```

---

## Rationale（设计决策）

| 决策 | 选择 | 理由 |
|------|------|------|
| 随机源 | `secrets` 模块 | 密码学安全，OS 级随机源；`random` 模块不适合密码生成 |
| 框架 | `argparse` 标准库 | 零依赖，符合 YAGNI |
| 字符集保证算法 | 先选各类代表字符再填充 | 保证每类至少出现一个字符，避免纯随机可能漏掉某类 |
| 文件位置 | `scripts/passgen.py` | 通用工具脚本目录，与现有工具保持一致 |

---

## Detailed Design（详细设计）

### 核心算法

```
1. 验证参数（length >= 4，至少一个字符集启用）
2. 构建字符集字典 {category: chars}（仅启用的类别）
3. 为每个启用类别各取 1 个字符（保证多样性）
4. 随机从合并字符池填充剩余 (length - enabled_count) 个字符
5. 用 SystemRandom.shuffle() 打乱顺序（避免强制字符聚集在头部）
6. 打印结果到 stdout
```

### 字符集定义

```python
CHARSETS = {
    "upper":   string.ascii_uppercase,           # A-Z
    "lower":   string.ascii_lowercase,           # a-z
    "digits":  string.digits,                    # 0-9
    "special": "!@#$%^&*()-_=+[]{}|;:,.<>?",   # 常用特殊字符
}
```

---

## Design Documents（设计文档）

- [BDD 规格说明](./bdd-specs.md) - 行为场景与测试策略
- [架构说明](./architecture.md) - 系统结构与组件详情
- [最佳实践](./best-practices.md) - 安全性、可用性与代码质量指南
