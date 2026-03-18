# Python CLI 密码生成器 — 设计文档

**日期**：2026-03-18
**状态**：Draft
**文件**：`scripts/password_generator.py`

---

## Context（背景）

项目 `scripts/` 目录下缺少一个用于快速生成安全密码的工具。用户需要一个可在终端直接运行的 CLI 工具，使用 Python 标准库，零外部依赖。

---

## Requirements（需求）

| 编号 | 描述 | 优先级 |
|------|------|--------|
| REQ-01 | 使用 `secrets` 模块生成密码，确保密码学安全随机性 | P0 |
| REQ-02 | 默认生成 16 位，包含字母（大小写）、数字、特殊字符 | P0 |
| REQ-03 | 支持 `--length` 参数指定密码长度（范围：4–128） | P0 |
| REQ-04 | 支持 `--no-digits`、`--no-symbols`、`--no-upper`、`--no-lower` 独立禁用字符类型 | P0 |
| REQ-05 | 零外部依赖，仅用 `argparse`、`secrets`、`string` | P0 |
| REQ-06 | 文件 < 200 行，函数 < 20 行 | P1 |
| REQ-07 | 严格类型注解（Type Hints） | P1 |
| REQ-08 | 文件头 3 行 metadata：INPUT / OUTPUT / POS | P1 |

---

## Rationale（决策依据）

- **`secrets` vs `random`**：`random` 使用梅森旋转算法（伪随机），`secrets` 调用操作系统 CSPRNG（如 `/dev/urandom`），密码学安全。
- **`argparse` vs `click`**：`argparse` 是标准库，零依赖，符合项目 YAGNI 原则；`click` 引入外部依赖，不必要。
- **最小化范围**：不做强度评估、批量生成、剪贴板复制等，保持文件 < 200 行。

---

## Detailed Design（详细设计）

### CLI 接口

```
python3 scripts/password_generator.py [OPTIONS]

OPTIONS:
  -l, --length INT     密码长度（默认：16，范围：4–128）
  --no-digits          禁用数字 (0-9)
  --no-symbols         禁用特殊字符 (!@#$%...)
  --no-upper           禁用大写字母 (A-Z)
  --no-lower           禁用小写字母 (a-z)
  -h, --help           显示帮助信息
```

### 示例用法

```bash
# 默认：16 位全字符集
python3 scripts/password_generator.py

# 32 位密码
python3 scripts/password_generator.py --length 32

# 仅字母 + 数字（无特殊字符）
python3 scripts/password_generator.py --no-symbols

# 8 位纯字母
python3 scripts/password_generator.py -l 8 --no-digits --no-symbols
```

### 函数架构

```
password_generator.py
├── parse_args() -> argparse.Namespace   # 参数解析，< 20 行
├── build_charset(args) -> str           # 构建字符集，< 20 行
├── generate_password(charset, length) -> str  # 核心生成逻辑，< 10 行
└── main() -> int                        # 入口协调，< 15 行
```

### 错误处理

- 所有字符类型被禁用 → 打印错误信息并 `sys.exit(1)`
- `--length` 超出范围（< 4 或 > 128）→ `argparse` 类型检查报错

---

## Out of Scope（明确排除）

- ❌ 密码强度/熵值计算
- ❌ 批量生成（`-n` 参数）
- ❌ 保存到文件或剪贴板
- ❌ 图形界面
- ❌ 强制规则（"至少含一个数字"）

---

## Design Documents

- [BDD Specifications](./bdd-specs.md) — 行为规格与测试场景
- [Architecture](./architecture.md) — 系统架构与组件详情
- [Best Practices](./best-practices.md) — 安全性、代码质量指南
