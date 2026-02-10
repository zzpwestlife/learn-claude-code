# 完整执行手册

## UltraWork + OpenSpec + Plan Agent + Sisyphus + Ralph Loop

本手册提供完整、可操作的执行步骤，实现用户认证 REST API。

---

## 目录

1. [前置条件](#前置条件)
2. [Phase 0: UltraWork 激活](#phase-0-ultrawork-激活)
3. [Phase 1: OpenSpec 规格验证](#phase-1-openspec-规格验证)
4. [Phase 2: Plan Agent 规划](#phase-2-plan-agent-规划)
5. [Phase 3: Sisyphus 任务执行](#phase-3-sisyphus-任务执行)
6. [Phase 4: Ralph Loop 质量保障](#phase-4-ralph-loop-质量保障)
7. [Phase 5: UltraWork 最终验证](#phase-5-ultrawork-最终验证)
8. [完整命令速查](#完整命令速查)

---

## 前置条件

### 环境准备

```bash
# 1. 确保在正确目录
cd /Users/joeyzou/Code/OpenSource/learn-claude-code/examples/ultrawork-complete-demo

# 2. 检查 Go 版本
go version  # 应为 1.21+

# 3. 安装依赖
go install github.com/stretchr/testify@latest
go install github.com/vektra/mockery/v2@latest

# 4. 确保 PostgreSQL 运行
# 5. 确保 Redis 运行
# 6. 设置环境变量
export AUTH_SECRET="your-secret-key-here"
export DATABASE_URL="postgres://user:pass@localhost:5432/auth_demo?sslmode=disable"
```

### 验证环境

```bash
# 检查 Go
go version

# 检查目录
pwd
ls -la
```

---

## Phase 0: UltraWork 激活

### 步骤 0.1: 激活 UltraWork 模式

在 Claude Code 中输入:

```
ULTRAWORK MODE ENABLED!

我需要实现一个用户认证 REST API，包含:
- POST /auth/register - 用户注册
- POST /auth/login - 用户登录
- POST /auth/refresh - JWT Token 刷新
- GET /auth/me - 获取当前用户信息

规格文件: examples/ultrawork-complete-demo/spec.json

请阅读 spec.json 并确认理解规格定义。
```

### 步骤 0.2: 确认理解

Claude 阅读 spec.json 后，回复确认:

```
我确认理解规格定义:

1. ✅ 功能需求:
   - 实现 4 个 REST API 端点
   - 用户注册、登录、Token 刷新、获取用户信息

2. ✅ 成功标准:
   - Functional: 4 个 API 端点功能正常
   - Observable: HTTP 状态码和响应格式正确
   - Pass/Fail: make test 通过, curl 测试全部绿色

3. ✅ 约束条件:
   - 安全性: bcrypt 哈希, JWT Secret 从环境变量
   - 性能: API 响应 < 200ms
   - 代码质量: >80% 测试覆盖率

4. ✅ 测试计划:
   - 6 个测试用例
   - 执行: make integration-test

我已准备好继续到规划阶段。
```

---

## Phase 1: OpenSpec 规格验证

### 步骤 1.1: 阅读完整规格

```bash
# 阅读 OpenSpec 定义
cat spec.json
```

### 步骤 1.2: 提取关键信息

| 分类 | 关键点 |
|------|--------|
| 端点 | 4 个 (register, login, refresh, me) |
| HTTP 方法 | POST, POST, POST, GET |
| 成功状态码 | 201, 200, 200, 200 |
| 认证 | JWT (Bearer Token) |
| 数据库 | PostgreSQL + Redis |

---

## Phase 2: Plan Agent 规划

### 步骤 2.1: 调用 Plan Agent

在 Claude Code 中:

```typescript
delegate_task(
  subagent_type="plan",
  description="规划用户认证API实现",
  prompt=`## 任务背景

项目: 用户认证 REST API
规格文件: examples/ultrawork-complete-demo/spec.json
语言: Go 1.21+ / Gin + GORM

## 用户需求

实现:
- POST /auth/register - 用户注册
- POST /auth/login - 用户登录
- POST /auth/refresh - JWT Token 刷新
- GET /auth/me - 获取当前用户信息

## 成功标准

从 spec.json 提取:
- Functional: 4 个 API 端点功能正常
- Pass/Fail: make test 通过

## 约束

- 安全性: bcrypt 哈希, JWT Secret 从环境变量
- 性能: API 响应 < 200ms
- 代码质量: >80% 测试覆盖率

## 项目结构

src/
├── main.go
├── config/
├── models/
├── handlers/
├── middleware/
├── services/
├── repository/
└── utils/

tests/
├── unit/
└── integration/

## 请输出

1. 依赖分析 (Go 依赖、外部服务)
2. 并行任务分析 (哪些可并行)
3. 串行任务分析 (依赖关系)
4. Parallel Task Graph (JSON)
5. 结构化 TODO 列表 (含 Category + Skills)

请开始分析并生成完整任务计划。`,
  run_in_background=false
)
```

### 步骤 2.2: 保存 Plan Session ID

Plan Agent 返回:

```json
{
  "session_id": "ses_plan_abc123",
  "waves": [...],
  "todos": [...]
}
```

**保存 session_id**: `ses_plan_abc123`

---

## Phase 3: Sisyphus 任务执行

### 步骤 3.1: 执行 Wave 1 (项目初始化)

```typescript
// 串行执行
delegate_task(
  session_id="ses_plan_abc123",
  category="unspecified-low",
  load_skills=["git-master"],
  description="初始化 Go 模块",
  prompt=`执行 W1-T1: 初始化 Go 模块

任务: 创建 go.mod, 项目目录, .gitignore

验收标准:
- go mod init auth-api 完成
- 目录创建: config, models, handlers, middleware, services, repository, utils, tests/unit, tests/integration
- .gitignore 创建
- go build ./... 成功

请执行并验证。`,
  run_in_background=false
)
```

```typescript
delegate_task(
  session_id="ses_plan_abc123",
  category="unspecified-low",
  description="创建配置文件",
  prompt=`执行 W1-T2: 创建配置文件

任务: 创建 config/config.go 和 .env.example

验收标准:
- config/config.go 包含 Config 结构体
- .env.example 包含所有必要环境变量
- go vet ./config/... 无警告

请执行并验证。`,
  run_in_background=false
)
```

### 步骤 3.2: 执行 Wave 2 (并行)

```typescript
// 并行执行 W2-T1, W2-T2, W2-T3
const w2t1 = delegate_task(
  session_id="ses_plan_abc123",
  category="quick",
  description="User 数据模型",
  prompt=`执行 W2-T1: 定义 User 数据模型

文件: models/user.go

验收标准:
- User 结构体定义完成
- TableName 方法实现
- go build ./models/... 成功`,
  run_in_background=true
)

const w2t2 = delegate_task(
  session_id="ses_plan_abc123",
  category="ultrabrain",
  description="JWT 工具",
  prompt=`执行 W2-T2: 实现 JWT 工具

文件: utils/jwt.go

验收标准:
- GenerateToken 函数实现
- ValidateToken 函数实现
- 从环境变量读取 Secret
- go vet ./utils/... 无警告`,
  run_in_background=true
)

const w2t3 = delegate_task(
  session_id="ses_plan_abc123",
  category="quick",
  description="密码哈希工具",
  prompt=`执行 W2-T3: 实现密码哈希

文件: utils/password.go

验收标准:
- HashPassword 函数实现
- CheckPassword 函数实现
- go test ./utils/... 通过`,
  run_in_background=true
)

// 等待所有完成
background_output(task_id=w2t1.task_id)
background_output(task_id=w2t2.task_id)
background_output(task_id=w2t3.task_id)
```

### 步骤 3.3: 更新 TODO 状态

```typescript
todowrite(todos=[
  {id: "W1-T1", content: "初始化 Go 模块", status: "completed"},
  {id: "W1-T2", content: "创建配置文件", status: "completed"},
  {id: "W2-T1", content: "定义 User 数据模型", status: "completed"},
  {id: "W2-T2", content: "实现 JWT 工具", status: "completed"},
  {id: "W2-T3", content: "实现密码哈希", status: "completed"},
  {id: "W3-T1", content: "实现 User Repository", status: "in_progress"},
  {id: "W4-T1", content: "实现 Auth Service", status: "pending"},
  {id: "W5-T1", content: "实现认证处理器", status: "pending"},
  {id: "W6-T1", content: "实现 JWT 中间件", status: "pending"},
  {id: "W6-T2", content: "注册路由", status: "pending"},
  {id: "W7-T1", content: "编写单元测试", status: "pending"},
  {id: "W7-T2", content: "编写集成测试", status: "pending"}
])
```

### 步骤 3.4: 继续执行剩余 Wave

```typescript
// W3-T1: Repository
delegate_task(
  session_id="ses_plan_abc123",
  category="quick",
  description="User Repository",
  prompt=`执行 W3-T1: 实现 User Repository

文件: repository/user.go

验收标准:
- Create, FindByID, FindByEmail, Update, Delete 实现
- go build ./repository/... 成功`,
  run_in_background=false
)

// W4-T1: Service (复杂业务逻辑)
delegate_task(
  session_id="ses_plan_abc123",
  category="ultrabrain",
  description="Auth Service",
  prompt=`执行 W4-T1: 实现 Auth Service

文件: services/auth.go

验收标准:
- Register, Login, Refresh, GetMe 实现
- 密码验证安全
- JWT 生成正确
- go vet ./services/... 无警告`,
  run_in_background=false
)

// W5-T1: Handler
delegate_task(
  session_id="ses_plan_abc123",
  category="quick",
  description="认证处理器",
  prompt=`执行 W5-T1: 实现认证处理器

文件: handlers/auth.go

验收标准:
- 4 个处理器实现
- 响应格式正确
- go build ./handlers/... 成功`,
  run_in_background=false
)

// W6: 中间件和路由
delegate_task(
  session_id="ses_plan_abc123",
  category="quick",
  description="JWT 中间件",
  prompt=`执行 W6-T1: 实现 JWT 认证中间件

文件: middleware/auth.go

验收标准:
- AuthRequired 中间件实现
- Token 验证正确
- 401 错误处理正确
- go build ./middleware/... 成功`,
  run_in_background=false
)

delegate_task(
  session_id="ses_plan_abc123",
  category="quick",
  description="注册路由",
  prompt=`执行 W6-T2: 注册路由

文件: main.go

验收标准:
- 4 个路由注册完成
- ./auth-api 编译成功`,
  run_in_background=false
)
```

### 步骤 3.5: 测试

```typescript
// W7-T1: 单元测试
delegate_task(
  session_id="ses_plan_abc123",
  category="deep",
  description="单元测试",
  prompt=`执行 W7-T1: 编写单元测试

文件: tests/unit/auth_test.go

验收标准:
- utils, services 单元测试覆盖
- 覆盖率 > 80%
- go test ./tests/unit/... -coverprofile=coverage.out

请执行并验证。`,
  run_in_background=false
)

// W7-T2: 集成测试
delegate_task(
  session_id="ses_plan_abc123",
  category="deep",
  description="集成测试",
  prompt=`执行 W7-T2: 编写集成测试

文件: tests/integration/auth_test.go

验收标准:
- 6 个测试用例全部实现
- make integration-test 通过
- 所有 API 端点测试绿色

请执行并验证。`,
  run_in_background=false
)
```

---

## Phase 4: Ralph Loop 质量保障

### 场景: 假设测试失败

```bash
# 运行测试
make test

# 假设输出:
# --- FAIL: TestLogin_InvalidPassword
#     auth_test.go:45: expected 401, got 500
```

### Ralph Loop 执行

```typescript
// Step 1: 回滚
bash(command="git status", description="查看修改")
bash(command="git stash", description="暂存更改")

// Step 2: 分析
console.log("测试失败: TestLogin_InvalidPassword")
console.log("期望: 401")
console.log("实际: 500")

// Step 3: 修复
bash(command="git stash pop", description="恢复更改")

// 定位问题
read(filePath="services/auth.go")

// 发现问题: 密码验证错误时返回了错误
edit(
  filePath="services/auth.go",
  oldString="func (s *AuthService) Login(input LoginInput) (string, string, error) {\n    user, err := s.repo.FindByEmail(input.Email)\n    if err != nil {\n        return \"\", \"\", err  // 这里泄露了用户是否存在\n    }\n    if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(input.Password)); err != nil {\n        return \"\", \"\", err  // 应该返回特定错误\n    }",
  newString="func (s *AuthService) Login(input LoginInput) (string, string, error) {\n    user, err := s.repo.FindByEmail(input.Email)\n    if err != nil {\n        if err == gorm.ErrRecordNotFound {\n            return \"\", \"\", errors.New(\"invalid credentials\")\n        }\n        return \"\", \"\", err\n    }\n    if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(input.Password)); err != nil {\n        if err == bcrypt.ErrMismatchedHashAndPassword {\n            return \"\", \"\", errors.New(\"invalid credentials\")\n        }\n        return \"\", \"\", err\n    }"
)

// Step 4: 重验证
bash(command="go test ./tests/unit/... -v -run TestLogin", description="重新运行测试")
// 输出: PASS
```

---

## Phase 5: UltraWork 最终验证

### 步骤 5.1: 对照 OpenSpec 逐项检查

```bash
# 1. Functional: 验证 API 功能
echo "=== 测试 POST /auth/register ==="
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"SecurePass123","name":"Test"}' \
  -w "\nStatus: %{http_code}\n"

echo "=== 测试 POST /auth/login ==="
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"SecurePass123"}' \
  -w "\nStatus: %{http_code}\n"

echo "=== 测试 POST /auth/refresh ==="
curl -X POST http://localhost:8080/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{"refreshToken":"<refresh_token>"}' \
  -w "\nStatus: %{http_code}\n"

echo "=== 测试 GET /auth/me ==="
curl -X GET http://localhost:8080/auth/me \
  -H "Authorization: Bearer <access_token>" \
  -w "\nStatus: %{http_code}\n"
```

### 步骤 5.2: Pass/Fail 验证

```bash
# 编译
go build ./...
# 预期: 退出码 0

# 单元测试
go test ./tests/unit/... -coverprofile=coverage.out
# 预期: 退出码 0, 覆盖率 > 80%

# 集成测试
make integration-test
# 预期: 退出码 0, 所有测试通过

# LSP 诊断
lsp_diagnostics(filePath="src/auth/")
# 预期: 无错误
```

### 步骤 5.3: 证据归档

```
=== UltraWork 最终验证报告 ===

日期: 2024-01-15
任务: 用户认证 REST API
Session: ses_plan_abc123

## 检查项

✅ F001: POST /auth/register → 201
✅ F002: POST /auth/login → 200 + JWT Token
✅ F003: POST /auth/refresh → 200 + 新 Token
✅ F004: GET /auth/me → 200 + 用户信息

✅ O001: HTTP 状态码正确
✅ O002: 响应格式一致
✅ O003: 错误消息可读

✅ P001: make test → 退出码 0
✅ P002: curl 测试 → 全部绿色
✅ P003: lsp_diagnostics → 无错误
✅ P004: go build → 编译成功

## 测试覆盖率

Unit Tests: 87.3%
Integration Tests: 100%

## 结论

✅ ALL PASS - 任务完成

## 证据截图

[在此处添加 curl 测试输出截图]
[在此处添加测试覆盖率截图]
```

---

## 附录 A：spec.json 是如何从多轮对话中生成的

在实际项目中，**spec.json 并非一蹴而就**，而是通过多轮对话逐步精化出来的。本节展示一个完整的多轮对话示例，演示如何从模糊需求演变成最终的规格定义。

### A.1 多轮对话流程概览

```
┌─────────────────────────────────────────────────────────────────────┐
│                        spec.json 生成流程                            │
└─────────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Round 1: 初始需求收集                                              │
│  用户提出模糊需求 → AI 记录但不实施                                  │
└─────────────────────────────────┬───────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Round 2: 需求澄清 (Metis/Planner 介入)                             │
│  AI 提问：哪些功能？优先级？约束？                                   │
└─────────────────────────────────┬───────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Round 3: 规格草稿生成                                              │
│  AI 生成初稿规格 → 用户确认/修改                                    │
└─────────────────────────────────┬───────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Round 4: 细化与验证                                               │
│  补充测试用例、约束、验收标准                                        │
└─────────────────────────────────┬───────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│  Round 5: 最终确认                                                 │
│  用户确认规格 → spec.json 锁定 → 进入实施阶段                       │
└─────────────────────────────────────────────────────────────────────┘
```

### A.2 多轮对话示例：用户认证 API

#### Round 1：初始需求收集

**用户输入：**

```
我需要一个用户认证的 API，包括注册、登录和获取用户信息的功能。
```

**AI 响应（记录需求，不实施）：**

```
我收到您的需求。让我先理解并确认一下：

## 需求记录

**功能需求：**
1. 用户注册
2. 用户登录
3. 获取用户信息

**待澄清事项：**
- Token 刷新功能是否需要？
- 使用什么认证方式（JWT、Session、OAuth）？
- 需要支持哪些第三方登录？
- 有无特殊的性能或安全要求？

在我开始实施之前，我需要更详细的信息。请回答以下问题：

1. **Token 管理**：
   - A) 需要 Token 刷新功能
   - B) 不需要 Token 刷新
   - C) 不确定，需要讨论

2. **认证方式**：
   - A) JWT Token（推荐）
   - B) Session/Cookie
   - C) 其他：______

3. **第三方登录**：
   - A) 不需要
   - B) 需要（请说明支持哪些平台）

4. **响应时间要求**：
   - A) < 100ms
   - B) < 200ms
   - C) < 500ms
   - D) 无特殊要求

5. **安全要求**：
   - A) 基本（密码哈希）
   - B) 标准（密码哈希 + Token 过期）
   - C) 严格（多因素认证等）
```

#### Round 2：需求澄清

**用户响应：**

```
1. A) 需要 Token 刷新功能
2. A) JWT Token
3. A) 不需要第三方登录
4. B) < 200ms
5. B) 标准（密码哈希 + Token 过期）
```

**AI 响应（生成规格草稿）：**

```
感谢确认。以下是我根据您的需求生成的规格草稿：

## 用户认证 API 规格草稿 v0.1

### 功能列表

| 功能 | 描述 | 优先级 |
|------|------|--------|
| 用户注册 | 创建新用户账户 | P0 |
| 用户登录 | 获取 JWT Token | P0 |
| Token 刷新 | 刷新过期 Token | P0 |
| 获取用户信息 | 获取当前用户详情 | P0 |

### API 端点设计

```
POST   /auth/register    - 用户注册
POST   /auth/login       - 用户登录
POST   /auth/refresh     - Token 刷新
GET    /auth/me          - 获取用户信息
```

### 响应格式（草稿）

**成功响应：**
```json
{
  "success": true,
  "data": { ... }
}
```

**错误响应：**
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "人类可读的错误信息"
  }
}
```

### 约束条件（草稿）

- [ ] JWT Access Token 过期时间：1 小时
- [ ] JWT Refresh Token 过期时间：7 天
- [ ] 密码必须 bcrypt 哈希存储
- [ ] API 响应时间 < 200ms

### 请确认或修改：

1. 以上端点设计是否正确？
2. Token 过期时间是否合适？
3. 响应格式是否可以接受？
4. 是否有遗漏的功能？

如有修改，请告诉我。
```

#### Round 3：规格确认与细化

**用户响应：**

```
端点设计正确，Token 时间也合适。但我需要：
1. 错误码要更详细，比如区分"邮箱已存在"和"密码错误"
2. 需要明确测试覆盖率的最低要求
3. 需要说明使用什么数据库
```

**AI 响应（生成细化规格）：**

```
好的，根据您的反馈，我细化规格如下：

## 用户认证 API 规格细化 v0.2

### 错误码定义

| 场景 | HTTP 状态码 | 错误码 | 消息 |
|------|-------------|--------|------|
| 邮箱已存在 | 409 | `EMAIL_EXISTS` | "邮箱已被注册" |
| 用户不存在 | 401 | `USER_NOT_FOUND` | "用户不存在或密码错误" |
| 密码错误 | 401 | `INVALID_PASSWORD` | "用户不存在或密码错误" |
| Token 过期 | 401 | `TOKEN_EXPIRED` | "Token 已过期，请刷新" |
| 无效 Token | 401 | `TOKEN_INVALID` | "无效的 Token" |
| 未授权访问 | 403 | `FORBIDDEN` | "无权访问此资源" |

### 响应时间约束

- API 整体响应时间 < 200ms
- 数据库查询时间 < 50ms

### 数据库要求

- 主数据库：PostgreSQL 14+
- 用户表：users（id, email, password_hash, name, role, created_at, updated_at）

### 测试要求

- 单元测试覆盖率 > 80%
- 集成测试覆盖所有 API 端点

### 请确认：

1. 错误码设计是否清晰？
2. 数据库选择（PostgreSQL）是否合适？
3. 测试覆盖率要求是否可接受？
4. 是否还有其他遗漏？
```

#### Round 4：最终规格确认

**用户响应：**

```
全部确认，开始实施吧。
```

**AI 响应（生成最终 spec.json）：**

```
完美！以下是最终的 spec.json 规格定义：

```json
{
  "version": "1.0.0",
  "title": "用户认证 REST API 规格定义",
  "description": "实现完整的用户认证系统，包含注册、登录、Token刷新和个人信息获取功能",
  "successCriteria": {
    "functional": [...],
    "observable": [...],
    "passFail": [...]
  },
  "constraints": {...},
  "testPlan": {...},
  "implementation": {...}
}
```

## 规格已锁定

- 版本：1.0.0
- 状态：待实施
- 创建时间：2024-01-15

**下一步**：进入 Phase 2 - Plan Agent 规划

如需修改规格，请明确说明。修改后将创建新版本。
```

### A.3 多轮对话模板

在实际项目中，可以使用以下模板进行需求收集：

#### AI 提问模板

```markdown
## 需求澄清

感谢您的需求！在开始实施之前，我需要确认几个关键问题：

### 1. 核心功能确认

您提到的功能是否包含：
- [ ] 功能 A
- [ ] 功能 B
- [ ] 功能 C
- [ ] 其他：______

### 2. 技术约束

请选择或说明：

**认证方式：**
- [ ] JWT Token
- [ ] Session/Cookie
- [ ] OAuth 2.0
- [ ] 其他：______

**数据库：**
- [ ] PostgreSQL
- [ ] MySQL
- [ ] MongoDB
- [ ] 其他：______

**性能要求：**
- [ ] < 100ms
- [ ] < 200ms
- [ ] < 500ms
- [ ] 无特殊要求

**安全要求：**
- [ ] 基本（数据正确即可）
- [ ] 标准（密码哈希、Token 过期）
- [ ] 严格（加密存储、审计日志等）

### 3. 测试要求

**测试覆盖率：**
- [ ] > 60%
- [ ] > 80%
- [ ] > 90%
- [ ] 不确定

**测试类型：**
- [ ] 只需要单元测试
- [ ] 需要集成测试
- [ ] 需要 E2E 测试

### 4. 交付物确认

以下哪些是必需的：
- [ ] 源代码
- [ ] 单元测试
- [ ] 集成测试
- [ ] API 文档
- [ ] 部署脚本

---

请回答以上问题，我将根据您的回答生成详细的规格定义。
```

#### 用户响应处理模板

```typescript
interface UserResponse {
  features: string[];
  authentication: "jwt" | "session" | "oauth" | "other";
  database: "postgresql" | "mysql" | "mongodb" | "other";
  performance: "<100ms" | "<200ms" | "<500ms" | "none";
  security: "basic" | "standard" | "strict";
  testCoverage: number;
  testTypes: ("unit" | "integration" | "e2e")[];
  deliverables: ("source" | "unit_test" | "integration_test" | "docs" | "deploy")[];
}

function generateSpec(response: UserResponse): Spec {
  // 根据用户响应生成 spec.json
  return {
    title: "...",
    successCriteria: {
      functional: generateFunctionalRequirements(response.features),
      observable: generateObservableCriteria(response.performance),
      passFail: generatePassFailCriteria(response.testTypes)
    },
    constraints: {
      security: generateSecurityConstraints(response.security),
      performance: generatePerformanceConstraints(response.performance),
      codeQuality: generateCodeQualityConstraints(response.testCoverage)
    },
    testPlan: generateTestPlan(response.testTypes),
    implementation: {
      database: response.database,
      authentication: response.authentication
    }
  };
}
```

### A.4 需求质量检查清单

在生成 spec.json 之前，AI 应该检查需求是否满足以下标准：

| 检查项 | 说明 | 示例 |
|--------|------|------|
| **具体性** | 需求是否具体可测量？ | ❌ "系统要快" → ✅ "响应时间 < 200ms" |
| **可测试性** | 是否有明确的验收标准？ | ❌ "用户能登录" → ✅ "POST /login 返回 200 + Token" |
| **独立性** | 功能是否独立最小化？ | ❌ "登录并管理个人资料" → 拆分为两个需求 |
| **完整性** | 是否包含所有必要信息？ | 端点、方法、参数、响应、错误码 |
| **一致性** | 各项之间是否一致？ | Token 过期时间与刷新策略匹配 |
| **可行性** | 在给定约束下是否可行？ | 性能要求是否合理 |

### A.5 常见问题与解决方案

| 问题 | 解决方案 |
|------|----------|
| 用户需求过于模糊 | 使用选择题式提问，引导用户明确 |
| 用户需求前后矛盾 | 列出矛盾点，请用户选择 |
| 用户不确定技术选型 | 提供推荐方案，说明优缺点 |
| 需求超出范围 | 明确标注 v1/v2 范围，建议分阶段实施 |
| 用户不断变更需求 | 每次变更创建新版本，记录变更日志 |

---

## 完整命令速查

| 阶段 | 命令 | 说明 |
|------|------|------|
| 初始化 | `go mod init auth-api` | 初始化 Go 模块 |
| 编译 | `go build ./...` | 编译项目 |
| 编译检查 | `go vet ./...` | 代码静态检查 |
| 运行测试 | `go test ./...` | 运行所有测试 |
| 覆盖率 | `go test ./... -coverprofile=c.out` | 生成覆盖率报告 |
| 集成测试 | `make integration-test` | 运行集成测试 |
| 启动服务 | `./auth-api` | 启动 API 服务 |
| 健康检查 | `curl http://localhost:8080/health` | 健康检查 |
| 注册 | `curl -X POST /auth/register` | 测试注册 |
| 登录 | `curl -X POST /auth/login` | 测试登录 |
| 刷新 | `curl -X POST /auth/refresh` | 测试刷新 |
| 用户信息 | `curl -X GET /auth/me` | 测试获取用户 |

---

## 文件清单

完成后的项目结构:

```
examples/ultrawork-complete-demo/
├── README.md                    # 项目说明
├── EXECUTION.md                 # 本执行手册
├── spec.json                    # OpenSpec 规格
├── ultrawork-activation.md     # UltraWork 激活模板
├── plan-prompt.md               # Plan Agent 提示词
├── sisyphus-delegation.md      # Sisyphus 委派模板
├── ralph-loop.md               # Ralph Loop 流程
├── go.mod                       # Go 模块
├── .env.example                 # 环境变量示例
├── main.go                      # 主入口
├── config/
│   └── config.go               # 配置
├── models/
│   └── user.go                  # 用户模型
├── handlers/
│   └── auth.go                  # HTTP 处理器
├── middleware/
│   └── auth.go                  # JWT 中间件
├── services/
│   └── auth.go                  # 业务逻辑
├── repository/
│   └── user.go                  # 数据访问
├── utils/
│   ├── jwt.go                   # JWT 工具
│   └── password.go              # 密码工具
└── tests/
    ├── unit/
    │   ├── jwt_test.go
    │   ├── password_test.go
    │   └── auth_test.go
    └── integration/
        └── auth_test.go
```

---

## 成功标准总结

| 标准 | 要求 | 验证方式 |
|------|------|----------|
| 功能完整 | 4 个 API 端点可用 | curl 测试 |
| 响应正确 | 状态码和格式符合 spec | 手动检查 |
| 测试覆盖 | >80% 单元测试 | coverage report |
| 代码质量 | 无 lint 错误 | go vet |
| 编译通过 | 退出码 0 | go build |
| 集成测试 | 全部通过 | make test |
