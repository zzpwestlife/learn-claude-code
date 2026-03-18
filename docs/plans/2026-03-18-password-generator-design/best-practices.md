# 最佳实践 - 密码生成器 (Web 版)

## 1. 安全性

### `crypto/rand` vs `math/rand`

| 属性 | `math/rand` | `crypto/rand` |
|------|-------------|---------------|
| 算法 | Mersenne Twister（伪随机） | OS 级 `/dev/urandom`（密码学安全） |
| 可预测性 | 可被逆推 | 不可预测 |
| 适用场景 | 模拟、游戏 | 密码、令牌、安全密钥 |

**结论**：密码生成必须使用 `crypto/rand`，禁止使用 `math/rand`。

### Fisher-Yates 洗牌

```go
// 正确：使用 crypto/rand 驱动的洗牌
for i := len(buf) - 1; i > 0; i-- {
    j, _ := randInt(i + 1)  // crypto/rand 实现
    buf[i], buf[j] = buf[j], buf[i]
}
```

**为什么需要洗牌**：强制字符（每类第 1 个）聚集在密码头部会创造可预测结构。洗牌消除位置偏差。

### 日志安全

- ❌ **禁止**在日志中打印生成的密码
- ❌ **禁止**在错误响应中回显用户输入的密码
- ✅ 仅记录请求参数（length、charset 标志），不记录结果

---

## 2. HTTP API 设计

### Content-Type

```go
w.Header().Set("Content-Type", "application/json; charset=utf-8")
```

始终在写入 body 之前设置 Content-Type，避免 Go 自动嗅探。

### 统一错误格式

```json
{
  "error": "invalid parameter",
  "details": "length must be at least 4, got 3"
}
```

使用独立的 `writeError(w, code, msg, details)` 函数，避免重复代码。

### HTTP 方法约束

```go
// Go 1.22+ ServeMux 支持方法匹配
mux.HandleFunc("GET /generate", handler.Generate)
```

对于不支持 1.22+ 的环境，在 handler 内手动检查：

```go
if r.Method != http.MethodGet {
    writeError(w, http.StatusMethodNotAllowed, "method not allowed", "")
    return
}
```

### CORS（本地开发）

本地开发学习用途，暂不配置 CORS。如需跨域访问，添加：

```go
w.Header().Set("Access-Control-Allow-Origin", "*")
```

---

## 3. 密码强度评分标准

### 熵值计算

```
H = L × log₂(N)

L = 密码长度
N = 启用的字符集总字符数（与 _index.md 字符集定义一致）
  - 小写字母：26
  - 大写字母：26
  - 数字：10
  - 特殊字符：32（见 _index.md 字符集定义）
  - 全部启用：94
```

### 评分映射

| Score | Label | Entropy 范围 | 示例 |
|-------|-------|-------------|------|
| 0 | Weak | < 40 bits | 4 位纯数字 |
| 1 | Fair | 40-59 bits | 8 位纯字母 |
| 2 | Good | 60-79 bits | 10 位混合字符 |
| 3 | Strong | 80-99 bits | 14 位全字符集 |
| 4 | Very Strong | ≥ 100 bits | 16 位以上全字符集 |

---

## 4. 代码质量

### 文件头（3 行强制）

```go
// INPUT: HTTP GET 请求，查询参数 length / no_upper / no_lower / no_digits / no_special
// OUTPUT: JSON 响应 {password, length, strength}
// POS: internal/handler/handler.go — HTTP 路由与请求处理
```

### 函数长度约束

每个函数 < 20 行，职责单一：

- `BuildCharsets()` — 仅构建字符集映射
- `Generate()` — 仅生成密码字符串
- `Score()` — 仅计算强度
- `handler.Generate()` — 仅处理 HTTP 请求/响应

### 禁止事项

- ❌ 使用 `math/rand` 生成密码
- ❌ 在日志中记录密码
- ❌ 引入任何第三方框架（gin、echo、chi 等）
- ❌ 函数超过 20 行
- ❌ 文件超过 200 行
- ❌ 注释掉的废弃代码

### `embed` 最佳实践

```go
// ui/embed.go
package ui

import "embed"

//go:embed index.html
var FS embed.FS
```

在 handler 中通过 `FS.ReadFile("index.html")` 读取，避免硬编码 HTML 字符串。

---

## 5. 测试质量

### 表格驱动测试（优先）

```go
func TestGenerate(t *testing.T) {
    tests := []struct{ name, query string; wantCode int }{...}
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) { ... })
    }
}
```

### 并发安全

```bash
go test ./... -race
```

`crypto/rand` 本身是并发安全的，但确保 handler 层无共享可变状态。

### 覆盖率目标

| 包 | 目标覆盖率 |
|----|-----------|
| `internal/generator` | ≥ 90% |
| `internal/strength` | ≥ 95% |
| `internal/handler` | ≥ 80% |
