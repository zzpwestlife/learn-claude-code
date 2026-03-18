# 密码生成器设计文档 (Web 版)

**日期**: 2026-03-18
**状态**: 设计完成，待实现
**版本**: 2.0（重新设计，Go HTTP Web 服务）

---

## Context（背景）

用户需要一个 Go 语言实现的 Web 密码生成器服务，通过 HTTP API 和简单 HTML 前端提供多用户访问能力。定位为学习用途，强调 Go 标准库的纯粹使用，无第三方框架依赖。

---

## Requirements（需求）

### 功能需求

1. **REST API** — `GET /generate` 接口，支持查询参数控制字符集和长度
2. **密码强度评分** — 响应中包含基于熵值的强度评分（0-4 分）
3. **JSON 响应** — 统一格式，包含 `password`、`length`、`strength` 字段
4. **HTML 前端页面** — `/` 路径，含复制按钮，浏览器可直接使用
5. **API 文档页面** — `/docs` 路径，手写 HTML，说明参数与示例
6. **参数校验** — 长度 ≥ 4，至少一个字符集启用，违规返回 400
7. **字符集保证** — 每个启用的字符集至少出现 1 个字符
8. **静态资源嵌入** — HTML 文件通过 `embed` 包编译进二进制

### 非功能需求

- **安全** — 使用 `crypto/rand` 作为随机源，Fisher-Yates 洗牌打乱顺序
- **代码质量** — 文件 < 200 行，函数 < 20 行，3 行文件头
- **零框架依赖** — 仅使用 Go 1.20+ 标准库
- **性能** — 本地环境响应延迟 < 100ms

---

## API Interface Specification（接口规格）

### 启动服务

```bash
go run ./cmd/server/
# 监听 :8080
```

### GET /generate

```
GET /generate?length=16&no_upper=false&no_lower=false&no_digits=false&no_special=false
```

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `length` | int | 16 | 密码长度，最小 4 |
| `no_upper` | bool | false | 禁用大写字母 A-Z |
| `no_lower` | bool | false | 禁用小写字母 a-z |
| `no_digits` | bool | false | 禁用数字 0-9 |
| `no_special` | bool | false | 禁用特殊字符 |

**成功响应 (200)**：

```json
{
  "password": "X7#mK9pQ@nL2vR4j",
  "length": 16,
  "strength": {
    "score": 4,
    "label": "Very Strong",
    "entropy": 104.9
  }
}
```

**错误响应 (400)**：

```json
{
  "error": "invalid parameter",
  "details": "length must be at least 4"
}
```

### GET /

HTML 前端页面，含参数配置 UI 和复制按钮。

### GET /docs

手写 HTML API 文档页面，含参数说明、示例请求和响应。

---

## Rationale（设计决策）

| 决策 | 选择 | 理由 |
|------|------|------|
| 随机源 | `crypto/rand` | 密码学安全，OS 级随机源；`math/rand` 不适合密码生成 |
| 洗牌算法 | Fisher-Yates + `crypto/rand` | 避免结构性偏差（强制字符聚集在首位） |
| HTTP 框架 | `net/http` 标准库 | 学习用途，理解底层；Go 1.22+ ServeMux 支持方法匹配 |
| 前端集成 | `//go:embed` 指令 | 单文件部署，无需额外静态文件服务逻辑 |
| 熵值计算 | H = L × log₂(N) | 可量化的安全指标，比正则检查更科学 |
| API 方法 | GET | 无副作用、浏览器直接访问、便于学习调试 |
| 错误格式 | JSON `{error, details}` | 统一格式，便于程序处理 |

---

## Detailed Design（详细设计）

### 目录结构

```
cmd/server/
└── main.go                    # 服务入口，组装依赖，启动 HTTP 服务

internal/
├── generator/
│   └── gen.go                 # 密码生成核心逻辑
├── strength/
│   └── score.go               # 熵值计算与强度评分
└── handler/
    └── handler.go             # HTTP 路由与请求处理

ui/
├── embed.go                   # //go:embed 声明
└── index.html                 # HTML 前端页面

go.mod                         # 模块定义（零外部依赖）
```

### 核心算法

```
密码生成流程：
1. 解析并校验参数（length ≥ 4，至少一个字符集启用）
2. 构建字符集映射 {category: chars}（仅启用类别）
3. 为每个启用类别各选 1 个字符（保证多样性）
4. 从合并字符池随机填充剩余 (length - enabled_count) 个字符
5. Fisher-Yates 洗牌打乱字符顺序
6. 返回 JSON 响应（含密码 + 强度评分）

熵值计算：
- H = L × log₂(N)
  - L = 密码长度
  - N = 启用的字符集总大小
  - 大写 26 + 小写 26 + 数字 10 + 特殊字符 32 = 最大 94

强度评分（0-4）：
- 0 (Weak)        : H < 40 bits
- 1 (Fair)        : H 40-59 bits
- 2 (Good)        : H 60-79 bits
- 3 (Strong)      : H 80-99 bits
- 4 (Very Strong) : H ≥ 100 bits
```

### 字符集定义

```go
var charsets = map[string]string{
    "upper":   "ABCDEFGHIJKLMNOPQRSTUVWXYZ",          // 26 个
    "lower":   "abcdefghijklmnopqrstuvwxyz",          // 26 个
    "digits":  "0123456789",                           // 10 个
    "special": "!@#$%^&*()-_=+[]{}|;:,.<>?/~`'\"\\", // 32 个
    // 总字符池最大：94 个
}
```

---

## Design Documents（设计文档）

- [BDD 规格说明](./bdd-specs.md) — 行为场景与测试策略
- [架构说明](./architecture.md) — 系统结构与组件详情
- [最佳实践](./best-practices.md) — 安全性、API 设计与代码质量指南
