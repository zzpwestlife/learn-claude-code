# Design: Password Generator CLI

**Date**: 2026-03-18
**Status**: Approved
**Author**: Principal Engineer (Claude)

---

## 1. 需求摘要

| 维度 | 决策 |
|------|------|
| 场景 | CLI 工具，命令行直接运行 |
| 输出 | print 到 stdout |
| 字符集 | 大小写字母（a-z, A-Z）+ 数字（0-9） |
| 长度 | 固定默认 16 位 |
| 数量 | 每次生成 1 个 |
| 随机源 | `secrets` 模块（密码安全级） |
| 语言 | Python 3.10+ |
| 路径 | `scripts/password_gen.py` |

---

## 2. 设计方案

### 方案 A：单文件纯函数（推荐）

```
scripts/password_gen.py
├── ALPHABET = string.ascii_letters + string.digits  # 62 字符
├── generate(length=16) -> str      # 核心函数，使用 secrets.choice
└── main()                          # CLI 入口，print 结果
```

**优点**：极简，零依赖，可测试，可被 import 复用。
**缺点**：无扩展性（若未来需要特殊符号需修改）。

### 方案 B：带 argparse 参数的 CLI

增加 `--length` 参数，允许用户覆盖默认长度。

**优点**：灵活，无需改代码即可调整。
**缺点**：多 ~10 行代码，当前需求不需要。

---

## 3. 选定方案

**方案 A + 最小化 argparse**（YAGNI 原则）：

- 默认长度 16，支持可选 `--length` 参数（20 行内实现）
- 无第三方依赖（仅 `secrets`、`string`、`argparse`——标准库）

---

## 4. 接口规范

```bash
# 默认调用
python scripts/password_gen.py
# → 输出: Kx9mT3bWqZ4vL8pN

# 指定长度
python scripts/password_gen.py --length 24
# → 输出: Kx9mT3bWqZ4vL8pNaB7cRd2e
```

---

## 5. 文件规范

- 头部 3 行 metadata（INPUT/OUTPUT/POS）
- 文件 < 200 行（预计 ~30 行）
- 函数 < 20 行
- 无注释废代码，无 `any` 类型
