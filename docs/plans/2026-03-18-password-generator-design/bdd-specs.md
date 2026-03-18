# BDD Specifications — Python CLI 密码生成器

## Feature: Password Generation CLI

```gherkin
Feature: 密码生成 CLI 工具
  作为一名注重安全的用户
  我希望通过 CLI 生成强随机密码
  以便在不依赖外部工具的情况下保护我的账户

  Background:
    Given 密码生成器脚本位于 scripts/password_generator.py
    And Python 3.10+ 已安装

  # ──────────────────────────────────
  # Happy Path Scenarios
  # ──────────────────────────────────

  Scenario: 默认密码生成（无参数）
    When 我运行 `python3 scripts/password_generator.py`
    Then 输出应为一个长度为 16 的字符串
    And 输出应同时包含字母、数字和特殊字符

  Scenario: 自定义密码长度
    When 我运行 `python3 scripts/password_generator.py --length 32`
    Then 输出应恰好为 32 个字符长

  Scenario: 禁用特殊字符
    When 我运行 `python3 scripts/password_generator.py --no-symbols`
    Then 输出不应包含任何特殊字符（如 !@#$%^&*）
    And 输出应包含字母和数字

  Scenario: 禁用数字
    When 我运行 `python3 scripts/password_generator.py --no-digits`
    Then 输出不应包含任何数字（0-9）

  Scenario: 禁用大写字母
    When 我运行 `python3 scripts/password_generator.py --no-upper`
    Then 输出不应包含任何大写字母（A-Z）

  Scenario: 组合禁用（仅小写字母）
    When 我运行 `python3 scripts/password_generator.py --no-digits --no-symbols --no-upper`
    Then 输出应只包含小写字母（a-z）

  Scenario: 短密码生成（最短长度）
    When 我运行 `python3 scripts/password_generator.py --length 4`
    Then 输出应恰好为 4 个字符

  # ──────────────────────────────────
  # Edge Cases
  # ──────────────────────────────────

  Scenario: 随机性验证（每次输出不同）
    When 我连续运行 `python3 scripts/password_generator.py` 两次
    Then 两次输出应不同（极高概率）

  Scenario: 长密码生成（最长长度）
    When 我运行 `python3 scripts/password_generator.py --length 128`
    Then 输出应恰好为 128 个字符

  # ──────────────────────────────────
  # Error Scenarios
  # ──────────────────────────────────

  Scenario: 所有字符类型被禁用时报错
    When 我运行 `python3 scripts/password_generator.py --no-digits --no-symbols --no-upper --no-lower`
    Then 程序应以非零退出码退出
    And 错误信息应包含 "Error: At least one character type must be enabled"

  Scenario: 长度超出上限时报错
    When 我运行 `python3 scripts/password_generator.py --length 200`
    Then 程序应以非零退出码退出
    And 错误信息应包含有效范围提示

  Scenario: 长度低于下限时报错
    When 我运行 `python3 scripts/password_generator.py --length 1`
    Then 程序应以非零退出码退出

  Scenario: 长度参数非整数时报错
    When 我运行 `python3 scripts/password_generator.py --length abc`
    Then 程序应以非零退出码退出
    And argparse 应显示类型错误提示
```

---

## Testing Strategy

### 单元测试覆盖点

| 测试目标 | 测试方法 | 预期结果 |
|----------|----------|----------|
| `generate_password` 长度 | 断言 `len(pwd) == length` | 恰好等于指定长度 |
| `generate_password` 字符集过滤 | 检查每个字符是否在合法集合中 | 100% 通过 |
| `build_charset` 全禁 | 捕获 `ValueError` | 抛出正确异常 |
| 随机性 | 生成 100 次，计数唯一值 | ≥ 99 个唯一 |
| argparse 边界值 | `--length 4`、`--length 128`、`--length 3` | 前两者成功，后者失败 |

### 随机性验证（统计）

```python
# 连续生成 1000 个密码，统计字符类别占比
# 预期：字母约 52/(52+10+32) ≈ 55%，数字约 11%，符号约 34%
```
