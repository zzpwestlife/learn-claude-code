# 架构说明 - 密码生成器 (Web 版)

## 目录结构

```
learn-claude-code/
├── cmd/
│   └── server/
│       └── main.go              # 服务入口：组装依赖，注册路由，启动 HTTP 服务
├── internal/
│   ├── generator/
│   │   ├── gen.go               # 密码生成核心逻辑（字符集、随机、洗牌）
│   │   └── gen_test.go          # 单元测试
│   ├── strength/
│   │   ├── score.go             # 熵值计算与强度评分
│   │   └── score_test.go        # 单元测试
│   └── handler/
│       ├── handler.go           # HTTP 路由与请求/响应处理
│       └── handler_test.go      # HTTP 集成测试（httptest）
├── ui/
│   ├── embed.go                 # //go:embed 声明
│   └── index.html               # HTML 前端页面（含 JS 复制逻辑）
├── go.mod                       # 模块定义（零外部依赖）
└── docs/plans/.../              # 本设计文档
```

## 模块职责

### `cmd/server/main.go`

```
职责：服务启动与依赖组装
│
├── 初始化 handler（注入 generator、strength 依赖）
├── 注册路由：
│   ├── GET /generate  → handler.Generate
│   ├── GET /          → handler.Index（HTML 前端）
│   └── GET /docs      → handler.Docs（API 文档）
└── log.Fatal(http.ListenAndServe(":8080", mux))
```

### `internal/generator/gen.go`

```
职责：生成密码核心逻辑

函数：
├── BuildCharsets(opts Options) (map[string]string, error)
│   # 根据 Options 构建启用的字符集映射
│
├── Generate(length int, charsets map[string]string) (string, error)
│   # 保证每类至少 1 字符 → 填充 → Fisher-Yates 洗牌
│
└── randByte(charset string) (byte, error)
    # crypto/rand 安全读取单个字节
```

### `internal/strength/score.go`

```
职责：密码强度评分

函数：
├── Score(password string, charsetSize int) Strength
│   # 计算熵值，返回 score(0-4) + label + entropy
│
└── CharsetSize(charsets map[string]string) int
    # 计算所有启用字符集的总字符数
```

### `internal/handler/handler.go`

```
职责：HTTP 请求处理

函数：
├── Generate(w, r) → JSON 响应
│   # 解析参数 → 调用 generator → 调用 strength → 写 JSON
│
├── Index(w, r) → HTML 页面（embed）
│
├── Docs(w, r) → HTML 文档（embed）
│
└── writeError(w, code, msg, details)
    # 统一错误响应格式
```

## 数据流

```
HTTP Request
    │
    ▼
handler.Generate(w, r)
    │
    ├── strconv.Atoi(r.FormValue("length"))
    ├── 解析 no_upper / no_lower / no_digits / no_special
    │
    ▼
generator.BuildCharsets(opts)
    │   → map[string]string / error
    │
    ▼
generator.Generate(length, charsets)
    │
    ├── 每类各取 1 个 crypto/rand 字节
    ├── 填充剩余字符
    ├── Fisher-Yates shuffle
    │
    └── string(result)
            │
            ▼
strength.Score(password, charsetSize)
    │   H = length × log₂(charsetSize)
    │   → {score, label, entropy}
    │
    ▼
json.NewEncoder(w).Encode(Response{...})
```

## 依赖关系

| 模块 | 用途 | 类型 |
|------|------|------|
| `net/http` | HTTP 服务器、路由 | 标准库 |
| `crypto/rand` | 密码学安全随机数 | 标准库 |
| `encoding/json` | JSON 序列化 | 标准库 |
| `embed` | 静态资源嵌入 | 标准库 |
| `math` | log2 熵值计算 | 标准库 |
| `strconv` | 参数类型转换 | 标准库 |

**零第三方依赖。**

## API Response Schema

```go
type Response struct {
    Password string   `json:"password"`
    Length   int      `json:"length"`
    Strength Strength `json:"strength"`
}

type Strength struct {
    Score   int     `json:"score"`   // 0-4
    Label   string  `json:"label"`   // "Weak" / "Fair" / "Good" / "Strong" / "Very Strong"
    Entropy float64 `json:"entropy"` // bits
}

type ErrorResponse struct {
    Error   string `json:"error"`
    Details string `json:"details"`
}
```
