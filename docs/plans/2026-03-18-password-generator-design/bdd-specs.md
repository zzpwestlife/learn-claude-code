# BDD 规格说明 - 密码生成器 (Web 版)

## Feature: 密码生成 HTTP 服务

```gherkin
Feature: 密码生成器 HTTP 服务
  作为一个需要安全密码的用户
  我希望通过 Web 界面或 API 快速生成高强度密码
  以便保护我的账户和数据

  Background:
    Given 密码生成服务已启动并在 8080 端口监听
    And Content-Type 响应头为 "application/json"

  # ── Happy Path ────────────────────────────────────────────────

  Scenario: 使用默认参数生成密码
    When 我发送 GET 请求到 "/generate"
    Then 响应状态码应为 200
    And 响应包含 "password" 字段，长度为 16
    And 响应包含 "strength.score" 字段，值在 0-4 之间
    And 响应包含 "strength.entropy" 字段，值大于 0
    And 密码包含大写字母、小写字母、数字和特殊字符各至少 1 个

  Scenario: 自定义密码长度
    When 我发送 GET 请求到 "/generate?length=32"
    Then 响应状态码应为 200
    And 响应中 "password" 的长度恰好为 32

  Scenario: 禁用特殊字符
    When 我发送 GET 请求到 "/generate?no_special=true"
    Then 响应状态码应为 200
    And 密码不包含任何特殊字符
    And 密码包含大写字母、小写字母和数字

  Scenario: 禁用多个字符集
    When 我发送 GET 请求到 "/generate?no_upper=true&no_special=true"
    Then 响应状态码应为 200
    And 密码不包含大写字母
    And 密码不包含特殊字符
    And 密码包含小写字母和数字

  Scenario: 仅数字（PIN 码场景）
    When 我发送 GET 请求到 "/generate?length=6&no_upper=true&no_lower=true&no_special=true"
    Then 响应状态码应为 200
    And 密码仅包含 0-9 的数字
    And 密码长度为 6

  Scenario: 超长密码
    When 我发送 GET 请求到 "/generate?length=128"
    Then 响应状态码应为 200
    And 密码长度为 128
    And "strength.score" 为 4

  # ── 密码强度评分 ────────────────────────────────────────────────

  Scenario: 短密码强度评分较低
    When 我发送 GET 请求到 "/generate?length=4&no_upper=true&no_special=true"
    Then 响应状态码应为 200
    And "strength.score" 小于 3
    And "strength.label" 为 "Weak" 或 "Fair"

  Scenario: 完整字符集长密码强度最高
    When 我发送 GET 请求到 "/generate?length=32"
    Then 响应状态码应为 200
    And "strength.score" 为 4
    And "strength.label" 为 "Very Strong"

  # ── 错误处理 ────────────────────────────────────────────────────

  Scenario: 密码长度低于最小值
    When 我发送 GET 请求到 "/generate?length=3"
    Then 响应状态码应为 400
    And 响应包含 "error" 字段
    And 响应包含关于最小长度的说明

  Scenario: 禁用所有字符集
    When 我发送 GET 请求到 "/generate?no_upper=true&no_lower=true&no_digits=true&no_special=true"
    Then 响应状态码应为 400
    And 响应包含 "error" 字段
    And 错误信息说明至少需要启用一个字符集

  Scenario: length 参数为非数字
    When 我发送 GET 请求到 "/generate?length=abc"
    Then 响应状态码应为 400
    And 响应包含 "error" 字段

  # ── 前端与文档页面 ──────────────────────────────────────────────

  Scenario: 访问 HTML 前端页面
    When 我发送 GET 请求到 "/"
    Then 响应状态码应为 200
    And Content-Type 包含 "text/html"
    And 响应包含密码输入框和复制按钮
    And 响应包含字符集选项控件

  Scenario: 访问 API 文档页面
    When 我发送 GET 请求到 "/docs"
    Then 响应状态码应为 200
    And Content-Type 包含 "text/html"
    And 页面包含 "/generate" 接口的参数说明
```

---

## 测试策略

### 单元测试（Go `testing` 标准库）

| 测试包 | 覆盖点 |
|--------|--------|
| `internal/generator` | 各字符集组合下的生成结果、每类至少 1 个字符的保证 |
| `internal/strength` | 熵值计算准确性、各分数区间边界 |
| `internal/handler` | 参数解析、错误响应格式（使用 `httptest`） |

### HTTP 集成测试（`net/http/httptest`）

```go
// 示例：测试 /generate 接口
req := httptest.NewRequest("GET", "/generate?length=16", nil)
w := httptest.NewRecorder()
handler.ServeHTTP(w, req)
// 断言：状态码 200，body 包含 password 字段
```

### 表格驱动测试

```go
tests := []struct {
    name     string
    query    string
    wantCode int
    wantLen  int
}{
    {"default", "/generate", 200, 16},
    {"length=32", "/generate?length=32", 200, 32},
    {"too_short", "/generate?length=3", 400, 0},
    {"no_charset", "/generate?no_upper=true&no_lower=true&no_digits=true&no_special=true", 400, 0},
}
```

### 测试文件位置

```
internal/generator/gen_test.go
internal/strength/score_test.go
internal/handler/handler_test.go
```

### 验证命令

```bash
go test ./...
go test ./... -race   # 并发安全检查
go vet ./...
```
