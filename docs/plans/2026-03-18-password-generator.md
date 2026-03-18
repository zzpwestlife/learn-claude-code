# Plan: Password Generator CLI

**Date**: 2026-03-18
**Design**: `docs/design/2026-03-18-password-generator.md`
**Status**: Ready to Execute

---

## Goal

实现一个密码安全级的 CLI 密码生成器，默认生成 16 位字母数字组合密码，支持 `--length` 可选参数。

---

## Architecture

```
scripts/password_gen.py          ← 唯一实现文件（~30 行）
tests/test_password_gen.py       ← BDD 测试文件
```

**依赖**：Python 标准库仅（`secrets`, `string`, `argparse`），零第三方依赖。

---

## Tech Stack

| 项目 | 版本 |
|------|------|
| Python | 3.10+ |
| 随机源 | `secrets.choice`（CSPRNG）|
| CLI 解析 | `argparse` |
| 测试框架 | `pytest` |

---

## BDD Scenarios

### Scenario 1: 默认生成 16 位密码
```gherkin
Given 用户运行 `python scripts/password_gen.py`
When  无任何参数
Then  输出恰好 16 个字符
And   所有字符属于 [a-zA-Z0-9]
And   退出码为 0
```

### Scenario 2: 指定长度生成密码
```gherkin
Given 用户运行 `python scripts/password_gen.py --length 24`
When  length=24
Then  输出恰好 24 个字符
And   所有字符属于 [a-zA-Z0-9]
```

### Scenario 3: 密码安全随机性
```gherkin
Given 调用 generate() 两次
When  length 相同
Then  两次结果不相同（概率极高）
```

### Scenario 4: 非法长度参数
```gherkin
Given 用户传入 --length 0 或负数
When  argparse 解析
Then  程序以非零退出码退出，并打印错误信息
```

---

## Tasks (Red-Green BDD Loop)

### Phase 1: 测试框架准备

**T1** — 确认测试目录与 pytest 可用
- Files: `tests/` 目录
- 操作: 检查 `tests/` 是否存在，`pytest` 是否可调用

---

### Phase 2: [Red] 写失败测试

**T2** — 创建 `tests/test_password_gen.py`
- Files: `tests/test_password_gen.py` (CREATE)
- 覆盖 Scenario 1、2、3、4 全部用例
- Step 1: [Red] 编写测试（此时 `scripts/password_gen.py` 不存在）
- Step 2: 运行 `pytest tests/test_password_gen.py` → 验证 **全部失败**（ImportError 或 AssertionError）

---

### Phase 3: [Green] 最小实现

**T3** — 创建 `scripts/password_gen.py`
- Files: `scripts/password_gen.py` (CREATE)
- 3 行 metadata 头
- `ALPHABET` 常量（62 字符）
- `generate(length: int = 16) -> str`
- `main()` + `argparse`（`--length`，类型 int，默认 16，最小值校验 ≥ 1）
- Step 3: [Green] 实现最小代码
- Step 4: 运行 `pytest tests/test_password_gen.py` → 验证 **全部通过**

---

### Phase 4: 验证与提交

**T4** — 最终验证
- 手动运行 `python scripts/password_gen.py` → 打印 16 位密码
- 手动运行 `python scripts/password_gen.py --length 8` → 打印 8 位密码
- 检查文件行数 < 200，函数行数 < 20

**T5** — Git 提交
- `git add scripts/password_gen.py tests/test_password_gen.py`
- `git commit -m "feat(scripts): add password generator CLI"`
