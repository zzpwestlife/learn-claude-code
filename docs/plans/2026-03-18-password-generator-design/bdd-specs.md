# BDD 规格说明 - 密码生成器

## Feature: 安全密码生成

```gherkin
Feature: 密码生成器 CLI 工具
  作为一个开发者
  我希望通过命令行快速生成安全密码
  以便保护我的账户和数据

  Background:
    Given 系统安装了 Python 3.10+

  Scenario: 默认参数生成 16 位密码
    Given 我运行 `python scripts/passgen.py`
    When 密码生成完成
    Then 输出的密码长度应为 16
    And 密码应包含至少一个大写字母
    And 密码应包含至少一个小写字母
    And 密码应包含至少一个数字
    And 密码应包含至少一个特殊字符
    And 退出码为 0

  Scenario: 自定义长度生成密码
    Given 我运行 `python scripts/passgen.py --length 32`
    When 密码生成完成
    Then 输出的密码长度应恰好为 32

  Scenario: 禁用特殊字符
    Given 我运行 `python scripts/passgen.py --no-special`
    When 密码生成完成
    Then 密码不应包含任何特殊字符
    And 密码应包含大写字母、小写字母和数字
    And 密码长度为 16

  Scenario: 禁用多个字符集
    Given 我运行 `python scripts/passgen.py --no-upper --no-special`
    When 密码生成完成
    Then 密码不应包含大写字母
    And 密码不应包含特殊字符
    And 密码应包含小写字母和数字

  Scenario: 仅数字（PIN 码场景）
    Given 我运行 `python scripts/passgen.py --length 6 --no-upper --no-lower --no-special`
    When 密码生成完成
    Then 输出应仅包含 0-9 的数字
    And 密码长度为 6

  Scenario: 超长密码
    Given 我运行 `python scripts/passgen.py --length 128`
    When 密码生成完成
    Then 输出的密码长度应为 128
    And 退出码为 0

  Scenario: 密码长度低于最小值
    Given 我运行 `python scripts/passgen.py --length 3`
    Then 程序应退出，退出码为非 0
    And stderr 应包含关于最小长度的错误信息

  Scenario: 所有字符集均禁用
    Given 我运行 `python scripts/passgen.py --no-upper --no-lower --no-digits --no-special`
    Then 程序应退出，退出码为非 0
    And stderr 应包含 "至少启用一种字符集" 的错误信息
```

## 测试策略

### 单元测试覆盖点

1. `build_charset()` - 各种标志组合下的字符集构建
2. `generate_password()` - 保证各类字符至少出现一个
3. 长度验证逻辑
4. 字符集为空时的错误处理

### 测试文件位置

`tests/test_passgen.py`

### 验证命令

```bash
python -m unittest tests.test_passgen -v
```
