# State: Password Generator CLI

> Auto-generated BDD state tracking file. Update status as tasks complete.

---

## Task Dependency Graph

```
T1 (环境检查)
 └── T2 [Red] 写失败测试
      └── T3 [Green] 最小实现
           └── T4 验证
                └── T5 提交
```

---

## Task Status

- [x] **T1** — 确认 tests/ 目录与 pytest 可用 *(Done)*
- [x] **T2** — [Red] 创建 `tests/test_password_gen.py`，验证全部失败 *(Done — ImportError confirmed)*
- [x] **T3** — [Green] 创建 `scripts/password_gen.py`，验证全部通过 *(Done — 7/7 PASSED)*
- [x] **T4** — 手动验证 CLI 行为 + 文件行数检查 *(Done — 32/65 lines, CLI outputs verified)*
- [x] **T5** — `git commit` 提交 *(Done — 43ce7fd)*

---

## BDD Coverage

| Scenario | 测试函数 | 状态 |
|----------|----------|------|
| 默认 16 位 | `test_default_length` | ⬜ Red |
| 指定长度 | `test_custom_length` | ⬜ Red |
| 安全随机性 | `test_randomness` | ⬜ Red |
| 非法长度 | `test_invalid_length` | ⬜ Red |

---

## Log

```
2026-03-18  Plan created. T1 unblocked, ready to execute.
```
