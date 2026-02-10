# Sisyphus 委派命令模板

## 委派原则

```
✅ DELEGATE BY DEFAULT: 能委派就委派
✅ 使用 Category + Skills: 领域优化模型
✅ 传递 session_id: 保持上下文
✅ 实时 TODO 跟踪: 标记 in_progress/completed
```

---

## Wave 1: 项目初始化

### W1-T1: 初始化 Go 模块

```typescript
delegate_task(
  session_id="{plan_session_id}",
  category="unspecified-low",
  load_skills=["git-master"],
  description="初始化 Go 模块",
  prompt=`## Task: W1-T1 - 初始化 Go 模块

### 1. TASK
创建 Go 模块和项目基础结构

### 2. EXPECTED OUTCOME
- go.mod 文件，包含: module auth-api, go 1.21
- 目录结构创建完成
- .gitignore 创建完成

### 3. REQUIRED TOOLS
- Bash (mkdir, cd, go mod init)
- Write (创建文件)
- Read (验证文件)

### 4. MUST DO
- [ ] 运行 \`go mod init auth-api\`
- [ ] 创建目录: config, models, handlers, middleware, services, repository, utils, tests/unit, tests/integration
- [ ] 从 https://github.com/github/gitignore/blob/main/Go.gitignore 创建 .gitignore
- [ ] 验证: \`go build ./...\` 成功

### 5. MUST NOT DO
- 不要修改其他任务的文件
- 不要删除任何现有文件
- 不要创建无关的文件

### 6. CONTEXT
- 项目根目录: /Users/joeyzou/Code/OpenSource/learn-claude-code/examples/ultrawork-complete-demo
- Plan Agent Session ID: {plan_session_id}
- 语言: Go 1.21+
- 框架: Gin + GORM

### 验证方法
运行 \`go build -o /dev/null ./...\` 确认退出码 0`,
  run_in_background=false
)
```

### W1-T2: 创建配置文件

```typescript
delegate_task(
  session_id="{plan_session_id}",
  category="unspecified-low",
  load_skills=[],
  description="创建配置文件",
  prompt=`## Task: W1-T2 - 创建配置文件

### 1. TASK
创建 config/config.go 和 .env.example

### 2. EXPECTED OUTCOME
- config/config.go - 配置结构体和加载函数
- .env.example - 环境变量示例
- config.yaml - 配置文件（可选）

### 3. REQUIRED TOOLS
- Write (创建 Go 文件)
- Read (验证语法)

### 4. MUST DO
- [ ] 定义 Config 结构体，包含:
  - Server (Host, Port)
  - Database (Host, Port, Name, User, Password, SSLMode)
  - JWT (Secret, ExpiryHours, RefreshExpiryHours)
  - Redis (Host, Port, Password)
- [ ] 实现 LoadConfig() 函数，从环境变量读取
- [ ] 创建 .env.example，包含所有必要环境变量
- [ ] 使用 Viper 或标准库 (建议标准库减少依赖)

### 5. MUST NOT DO
- 不要硬编码任何密钥或密码
- 不要使用 any 类型
- 不要省略错误处理

### 6. CONTEXT
- 依赖: 无外部依赖
- 文件: config/config.go

### 验证方法
运行 \`go vet ./config/...\` 确认无警告`,
  run_in_background=false
)
```

---

## Wave 2: 核心模型和工具

### W2-T1: 定义 User 数据模型

```typescript
delegate_task(
  session_id="{plan_session_id}",
  category="quick",
  load_skills=[],
  description="定义 User 数据模型",
  prompt=`## Task: W2-T1 - 定义 User 数据模型

### 1. TASK
创建 models/user.go，包含 User 结构体和 GORM 模型

### 2. EXPECTED OUTCOME
- models/user.go 文件
- User 结构体: ID, Email, Password, Name, Role, CreatedAt, UpdatedAt
- GORM TableName 方法
- 可能的迁移文件

### 3. REQUIRED TOOLS
- Write (创建模型文件)
- Read (验证语法)

### 4. MUST DO
- [ ] 定义 User 结构体
- [ ] 使用 gorm.Model 作为基类
- [ ] 添加 validation tags (如: validate:"required,email")
- [ ] 添加 TableName 方法
- [ ] 密码字段应该只存储哈希，不要明文

### 5. MUST NOT DO
- 不要在结构体中存储明文密码
- 不要使用 any 类型
- 不要省略 JSON/Schema tags

### 6. CONTEXT
- 框架: GORM v2
- 数据库: PostgreSQL

### 验证方法
运行 \`go build ./models/...\` 确认编译成功`,
  run_in_background=false
)
```

### W2-T2: 实现 JWT 工具

```typescript
delegate_task(
  session_id="{plan_session_id}",
  category="ultrabrain",
  load_skills=[],
  description="实现 JWT 工具函数",
  prompt=`## Task: W2-T2 - 实现 JWT 工具函数

### 1. TASK
创建 utils/jwt.go，实现 JWT 生成和验证

### 2. EXPECTED OUTCOME
- utils/jwt.go 文件
- GenerateToken(userID, email, role) -> (accessToken, refreshToken, error)
- ValidateToken(token string) -> (claims, error)
- RefreshToken(claims) -> (newAccessToken, newRefreshToken, error)

### 3. REQUIRED TOOLS
- Write (创建工具文件)
- Read (验证 JWT 库文档)

### 4. MUST DO
- [ ] 使用 github.com/golang-jwt/jwt/v5
- [ ] 定义 Claims 结构体: UserID, Email, Role, StandardClaims
- [ ] 实现 GenerateAccessToken
- [ ] 实现 GenerateRefreshToken
- [ ] 实现 ValidateToken
- [ ] Secret 必须从环境变量读取 (config.JWT.Secret)
- [ ] Token 过期时间从配置读取

### 5. MUST NOT DO
- 不要硬编码 Secret
- 不要使用 any 类型断言
- 不要忽略 Token 过期验证
- 不要记录敏感信息

### 6. CONTEXT
- JWT 库: golang-jwt/jwt
- 安全要求: HS256 算法

### 验证方法
运行 \`go vet ./utils/...\`，然后运行单元测试`,
  run_in_background=false
)
```

### W2-T3: 实现密码哈希

```typescript
delegate_task(
  session_id="{plan_session_id}",
  category="quick",
  load_skills=[],
  description="实现密码哈希工具",
  prompt=`## Task: W2-T3 - 实现密码哈希工具

### 1. TASK
创建 utils/password.go，实现密码哈希和验证

### 2. EXPECTED OUTCOME
- utils/password.go 文件
- HashPassword(password string) -> (hash string, error)
- CheckPassword(password, hash string) -> (bool, error)

### 3. REQUIRED TOOLS
- Write (创建工具文件)
- Read (验证 bcrypt 库文档)

### 4. MUST DO
- [ ] 使用 golang.org/x/crypto/bcrypt
- [ ] HashPassword: 使用 bcrypt.GenerateFromPassword
- [ ] CheckPassword: 使用 bcrypt.CompareHashAndPassword
- [ ] cost 设置为 10 或从配置读取
- [ ] 返回清晰的错误消息

### 5. MUST NOT DO
- 不要使用不安全的哈希算法 (如 MD5, SHA1)
- 不要记录原始密码
- 不要使用 any 类型

### 6. CONTEXT
- 库: golang.org/x/crypto/bcrypt
- 安全: 至少 cost 10

### 验证方法
运行 \`go test ./utils/... -v\``,
  run_in_background=false
)
```

---

## Wave 3: Repository 层

### W3-T1: 实现 User Repository

```typescript
delegate_task(
  session_id="{plan_session_id}",
  category="quick",
  load_skills=[],
  description="实现 User Repository",
  prompt=`## Task: W3-T1 - 实现 User Repository

### 1. TASK
创建 repository/user.go，实现用户数据访问

### 2. EXPECTED OUTCOME
- repository/user.go 文件
- Create(user *models.User) error
- FindByID(id string) (*models.User, error)
- FindByEmail(email string) (*models.User, error)
- Update(user *models.User) error
- Delete(id string) error

### 3. REQUIRED TOOLS
- Write (创建 Repository 文件)
- Read (参考 GORM 文档)

### 4. MUST DO
- [ ] 注入 *gorm.DB 到 Repository
- [ ] 实现 Create: 使用 GORM Create
- [ ] 实现 FindByID: 使用 First 或 Last
- [ ] 实现 FindByEmail: 使用 Where + First
- [ ] 实现 Update: 使用 Save 或 Updates
- [ ] 实现 Delete: 使用 Delete (软删除考虑)
- [ ] 处理 gorm.ErrRecordNotFound

### 5. MUST NOT DO
- 不要在 Repository 中包含业务逻辑
- 不要省略错误处理
- 不要使用 any 类型

### 6. CONTEXT
- 框架: GORM v2
- 模型: models.User

### 验证方法
运行 \`go build ./repository/...\``,
  run_in_background=false
)
```

---

## Wave 4: Service 层

### W4-T1: 实现 Auth Service

```typescript
delegate_task(
  session_id="{plan_session_id}",
  category="ultrabrain",
  load_skills=[],
  description="实现 Auth Service",
  prompt=`## Task: W4-T1 - 实现 Auth Service

### 1. TASK
创建 services/auth.go，实现核心业务逻辑

### 2. EXPECTED OUTCOME
- services/auth.go 文件
- Register(input RegisterInput) (*models.User, string, error)
- Login(input LoginInput) (string, string, error)
- Refresh(refreshToken string) (string, string, error)
- GetMe(userID string) (*models.User, error)

### 3. REQUIRED TOOLS
- Write (创建 Service 文件)
- Read (验证 JWT 和 bcrypt 库使用)

### 4. MUST DO
- [ ] 注入 Repository 和 JWT Utils
- [ ] Register:
  - 检查邮箱是否已存在
  - 哈希密码
  - 创建用户
  - 返回用户信息
- [ ] Login:
  - 查找用户
  - 验证密码
  - 生成 JWT tokens
- [ ] Refresh:
  - 验证 refresh token
  - 生成新的 access token
- [ ] GetMe:
  - 根据 userID 获取用户
  - 返回用户信息（不包含密码）

### 5. MUST NOT DO
- 不要返回明文密码
- 不要在日志中记录密码
- 不要使用 any 类型
- 不要泄露用户是否存在的信息（邮箱检查时的安全考虑）

### 6. CONTEXT
- 依赖: repository.UserRepository, utils.JWT
- 安全: 遵循安全最佳实践

### 验证方法
运行 \`go vet ./services/...\``,
  run_in_background=false
)
```

---

## Wave 5: Handler 层

### W5-T1: 实现认证处理器

```typescript
delegate_task(
  session_id="{plan_session_id}",
  category="quick",
  load_skills=[],
  description="实现认证处理器",
  prompt=`## Task: W5-T1 - 实现认证处理器

### 1. TASK
创建 handlers/auth.go，处理 HTTP 请求

### 2. EXPECTED OUTCOME
- handlers/auth.go 文件
- Register(c *gin.Context)
- Login(c *gin.Context)
- Refresh(c *gin.Context)
- Me(c *gin.Context)

### 3. REQUIRED TOOLS
- Write (创建 Handler 文件)
- Read (参考 Gin 框架文档)

### 4. MUST DO
- [ ] 注入 AuthService
- [ ] Register:
  - 绑定 JSON 到 RegisterInput
  - 调用 service.Register
  - 返回 201 和用户信息
- [ ] Login:
  - 绑定 JSON 到 LoginInput
  - 调用 service.Login
  - 返回 200 和 tokens
- [ ] Refresh:
  - 绑定 JSON 到 RefreshInput
  - 调用 service.Refresh
  - 返回 200 和新 tokens
- [ ] Me:
  - 从 context 获取 userID (从 JWT claims)
  - 调用 service.GetMe
  - 返回 200 和用户信息
- [ ] 统一的响应格式: {success: bool, data: interface{}, error: *Error}

### 5. MUST NOT DO
- 不要省略请求体验证
- 不要返回密码字段
- 不要使用 any 类型
- 不要忽略错误处理

### 6. CONTEXT
- 框架: Gin
- 响应格式: OpenSpec 定义

### 验证方法
运行 \`go build ./handlers/...\``,
  run_in_background=false
)
```

---

## Wave 6: 中间件和路由

### W6-T1: 实现 JWT 认证中间件

```typescript
delegate_task(
  session_id="{plan_session_id}",
  category="quick",
  load_skills=[],
  description="实现 JWT 认证中间件",
  prompt=`## Task: W6-T1 - 实现 JWT 认证中间件

### 1. TASK
创建 middleware/auth.go，保护认证路由

### 2. EXPECTED OUTCOME
- middleware/auth.go 文件
- AuthRequired() gin.HandlerFunc

### 3. REQUIRED TOOLS
- Write (创建中间件文件)
- Read (参考 Gin 中间件文档)

### 4. MUST DO
- [ ] 从 Authorization header 提取 Bearer token
- [ ] 调用 utils.JWT.ValidateToken
- [ ] 将 claims 存入 context (常key: "userID", "email", "role")
- [ ] 处理无效 token: 返回 401
- [ ] 处理过期 token: 返回 401 + "TOKEN_EXPIRED"

### 5. MUST NOT DO
- 不要允许空 token 通过
- 不要在 error 中泄露敏感信息
- 不要使用 any 类型

### 6. CONTEXT
- 依赖: utils.JWT
- 路由: /auth/me 需要此中间件

### 验证方法
运行 \`go build ./middleware/...\``,
  run_in_background=false
)
```

### W6-T2: 注册路由

```typescript
delegate_task(
  session_id="{plan_session_id}",
  category="quick",
  load_skills=[],
  description="注册路由到主应用",
  prompt=`## Task: W6-T2 - 注册路由

### 1. TASK
在 main.go 中注册所有认证路由

### 2. EXPECTED OUTCOME
- main.go 文件更新
- POST /auth/register → handlers.Register
- POST /auth/login → handlers.Login
- POST /auth/refresh → handlers.Refresh
- GET /auth/me → middleware.AuthRequired → handlers.Me

### 3. REQUIRED TOOLS
- Read (读取 main.go)
- Write (更新路由注册)

### 4. MUST DO
- [ ] 初始化 Gin 路由
- [ ] 初始化所有依赖 (Config, Repository, Service, Handler)
- [ ] 创建 /auth 路由组
- [ ] 注册公开路由: register, login, refresh
- [ ] 注册受保护路由: me (使用 AuthRequired 中间件)
- [ ] 添加健康检查路由: GET /health

### 5. MUST NOT DO
- 不要修改其他模块的代码
- 不要添加未使用的导入
- 不要删除现有的路由（如果有）

### 6. CONTEXT
- 框架: Gin
- 端口: 从配置读取 (default: 8080)

### 验证方法
运行 \`go build -o auth-api .\` 然后 \`./auth-api -h\``,
  run_in_background=false
)
```

---

## Wave 7: 测试

### W7-T1: 编写单元测试

```typescript
delegate_task(
  session_id="{plan_session_id}",
  category="deep",
  load_skills=[],
  description="编写单元测试",
  prompt=`## Task: W7-T1 - 编写单元测试

### 1. TASK
创建 tests/unit/auth_test.go

### 2. EXPECTED OUTCOME
- tests/unit/auth_test.go 文件
- 覆盖率 > 80%
- 测试文件结构:
  - utils/ (jwt_test.go, password_test.go)
  - services/auth_test.go

### 3. REQUIRED TOOLS
- Write (创建测试文件)
- Bash (运行测试)

### 4. MUST DO
- [ ] utils/jwt_test.go:
  - TestGenerateToken
  - TestValidateToken_Valid
  - TestValidateToken_Invalid
  - TestValidateToken_Expired
- [ ] utils/password_test.go:
  - TestHashPassword
  - TestCheckPassword_Valid
  - TestCheckPassword_Invalid
- [ ] services/auth_test.go (使用 mockery 生成 mock):
  - TestRegister_Success
  - TestRegister_EmailExists
  - TestLogin_Success
  - TestLogin_InvalidPassword
  - TestRefresh_Success

### 5. MUST NOT DO
- 不要跳过测试
- 不要使用 t.SkipNow()
- 不要创建无法通过的测试
- 不要依赖真实数据库（使用 mock）

### 6. CONTEXT
- 测试框架: standard library testing
- Mock 库: mockery (或 testify/mock)

### 验证方法
运行 \`go test ./tests/unit/... -coverprofile=coverage.out\` 确认覆盖率 > 80%`,
  run_in_background=false
)
```

### W7-T2: 编写集成测试

```typescript
delegate_task(
  session_id="{plan_session_id}",
  category="deep",
  load_skills=[],
  description="编写集成测试",
  prompt=`## Task: W7-T2 - 编写集成测试

### 1. TASK
创建 tests/integration/auth_test.go

### 2. EXPECTED OUTCOME
- tests/integration/auth_test.go 文件
- 测试所有 API 端点
- 使用 Testcontainers 或真实数据库

### 3. REQUIRED TOOLS
- Write (创建测试文件)
- Bash (运行测试)

### 4. MUST DO
- [ ] 使用 suite 模式组织测试
- [ ] SetupSuite: 初始化数据库连接
- [ ] TearDownSuite: 清理数据库
- [ ] TestRegister:
  - TC001: 成功注册
  - TC002: 邮箱已存在 (409)
  - TC003: 无效邮箱 (400)
- [ ] TestLogin:
  - TC004: 成功登录
  - TC005: 密码错误 (401)
  - TC006: 用户不存在 (401)
- [ ] TestRefresh:
  - TC007: 使用有效 refresh token
  - TC008: 使用无效 refresh token (401)
- [ ] TestMe:
  - TC009: 使用有效 token 获取
  - TC010: 无 token (401)
  - TC011: 无效 token (401)

### 5. MUST NOT DO
- 不要跳过集成测试
- 不要硬编码数据库连接
- 不要忘记清理测试数据

### 6. CONTEXT
- 测试框架: standard library testing
- 数据库: PostgreSQL (使用 Testcontainers 或手动设置)

### 验证方法
运行 \`make integration-test\` 确认所有测试通过`,
  run_in_background=false
)
```

---

## 实时 TODO 跟踪

每个任务完成后，更新 TODO:

```typescript
// 在 main session 中执行
todowrite(todos=[
  {id: "W1-T1", content: "初始化 Go 模块", status: "completed"},
  {id: "W1-T2", content: "创建配置文件", status: "completed"},
  {id: "W2-T1", content: "定义 User 数据模型", status: "in_progress"},
  // ...
])
```

---

## 批量并行执行 (Wave 2 优化)

对于可以并行的任务:

```typescript
// 并行执行 W2-T1, W2-T2, W2-T3
const w2t1 = delegate_task(
  session_id=planSessionId,
  category="quick",
  prompt="执行 W2-T1: User 数据模型",
  run_in_background=true
)

const w2t2 = delegate_task(
  session_id=planSessionId,
  category="ultrabrain",
  prompt="执行 W2-T2: JWT 工具",
  run_in_background=true
)

const w2t3 = delegate_task(
  session_id=planSessionId,
  category="quick",
  prompt="执行 W2-T3: 密码哈希",
  run_in_background=true
)

// 等待所有完成
background_output(task_id=w2t1.task_id)
background_output(task_id=w2t2.task_id)
background_output(task_id=w2t3.task_id)
```
