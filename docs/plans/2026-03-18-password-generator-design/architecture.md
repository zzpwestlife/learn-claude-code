# Architecture — Python CLI 密码生成器

## 文件结构

```
scripts/
└── password_generator.py   # 单文件，< 200 行
```

## 模块依赖（全标准库）

```
password_generator.py
├── import secrets     # CSPRNG，密码学安全随机
├── import string      # 字符集常量（ascii_letters, digits, punctuation）
└── import argparse    # CLI 参数解析
```

## 函数架构

```
main() -> int                          ← 入口，协调所有流程
├── parse_args() -> argparse.Namespace ← 参数定义与解析
├── build_charset(args) -> str         ← 根据参数构建字符集
│   ├── 包含字母（大/小写分别控制）
│   ├── 包含数字（--no-digits 禁用）
│   └── 包含特殊字符（--no-symbols 禁用）
└── generate_password(charset, length) -> str ← 核心生成逻辑
    └── secrets.choice(charset) × length
```

## 数据流

```
CLI Args
   ↓
parse_args()  →  argparse.Namespace
   ↓
build_charset()  →  str（合法字符集）
   ↓                 ↑ ValueError（字符集为空）
generate_password()  →  str（密码）
   ↓
print(password)  →  stdout
```

## 错误边界

| 错误场景 | 抛出位置 | 处理位置 |
|----------|----------|----------|
| 字符集为空 | `build_charset()` → `ValueError` | `main()` 捕获 → stderr + exit(1) |
| 长度越界（< 4 或 > 128） | `argparse type=` 校验 | `argparse` 自动输出错误 |
| 长度非整数 | `argparse type=int` | `argparse` 自动输出错误 |

## 文件头 Metadata（规范要求）

```python
# INPUT: CLI arguments: --length, --no-digits, --no-symbols, --no-upper, --no-lower
# OUTPUT: A secure random password string printed to stdout
# POS: scripts/password_generator.py
```

## 代码规模预估

| 函数 | 预估行数 |
|------|----------|
| `parse_args()` | ~18 行 |
| `build_charset()` | ~12 行 |
| `generate_password()` | ~5 行 |
| `main()` | ~12 行 |
| imports + metadata | ~8 行 |
| **合计** | **~55 行** |
