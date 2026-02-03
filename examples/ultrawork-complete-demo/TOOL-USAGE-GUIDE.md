# UltraWork 完整工作流工具使用指南

## 📋 文档说明

本文档使用 **emoji 标记** 展示在每个开发步骤中使用了哪些工具，以及**为什么**使用这些工具。

---

## 🗺️ 工具使用总览

### 工具分类 Emoji

| 工具类型 | Emoji | 描述 |
|----------|-------|------|
| **Agent** | 🤖 | 子Agent委派 |
| **Bash** | 💻 | 命令行执行 |
| **Write** | ✍️ | 文件写入 |
| **Read** | 📖 | 文件读取 |
| **Edit** | ✏️ | 文件编辑 |
| **Todo** | ✅ | 任务管理 |
| **Delegate** | 📋 | 委派任务 |
| **Background** | ⏳ | 后台任务 |
| **Verify** | 🔍 | 验证检查 |
| **Consult** | 🔮 | 专家咨询 |

---

# 第一部分：需求澄清阶段

## 🎯 对话轮次 1：初始需求提出

### 用户输入

```
我需要做一个用户认证的 API，包括注册、登录和获取用户信息的功能。
技术栈是 Go + Gin + GORM + PostgreSQL。
```

### AI 响应（🤖🔮 Metis/Planner 介入）

```
🤖 **工具**: `delegate_task(subagent_type="metis")`
📝 **原因**: 需求模糊，需要需求分析专家介入进行澄清

---

我收到您的需求。在开始实施之前，我需要通过几个澄清问题来确保完全理解您的需求。
```

---

## 🎯 对话轮次 2：用户回答与规格生成

### 用户输入

```
1. A) 需要 Token 刷新功能
2. A) Access Token 1小时，Refresh Token 7天
3. A) 基本 bcrypt 哈希即可
4. B) HTTP 状态码 + 错误码 + 错误消息
5. B) > 80%
6. B) < 200ms
```

### AI 响应（🤖🔮 Planner 生成规格草稿）

```
🤖 **工具**: `delegate_task(subagent_type="plan")`
📝 **原因**: 将用户回答转换为结构化规格定义

---

感谢您的回答！我现在生成规格草稿。

## 用户认证 API 规格定义 v0.1

### 功能规格

| 功能 | 端点 | 方法 | HTTP 状态码 | 描述 |
|------|------|------|-------------|------|
| 用户注册 | /auth/register | POST | 201 | 创建新用户 |
| 用户登录 | /auth/login | POST | 200 | 获取 JWT Token |
| Token 刷新 | /auth/refresh | POST | 200 | 获取新 Token |
| 获取用户信息 | /auth/me | GET | 200 | 获取当前用户详情 |

### 约束条件

| 类型 | 要求 |
|------|------|
| 安全性 | bcrypt 哈希存储密码 |
| 安全性 | JWT Secret 从环境变量读取 |
| 安全性 | Access Token 1小时过期，Refresh Token 7天过期 |
| 性能 | API 响应时间 < 200ms |
| 质量 | 单元测试覆盖率 > 80% |
| 质量 | 无 any 类型断言 |

### 初步测试用例

| ID | 场景 | 输入 | 预期输出 |
|----|------|------|----------|
| TC001 | 注册成功 | POST /auth/register | 201 + 用户信息 |
| TC002 | 邮箱已存在 | POST /auth/register | 409 + EMAIL_EXISTS |
| TC003 | 登录成功 | POST /auth/login | 200 + JWT Token |
| TC004 | 密码错误 | POST /auth/login | 401 + INVALID_PASSWORD |
| TC005 | Token 刷新 | POST /auth/refresh | 200 + 新 Token |
| TC006 | 获取用户 | GET /auth/me | 200 + 用户详情 |

---

### 请确认或修改
```

---

## 🎯 对话轮次 3-4：规格确认与锁定

### 用户确认

```
确认，开始实施吧。
```

### AI 响应（✍️📄 规格锁定）

```
✍️ **工具**: `write(filePath="spec.json")`
📝 **原因**: 将确认的规格写入 spec.json 文件，作为后续开发的唯一真相来源

🤖 **工具**: `delegate_task(subagent_type="metis")`
📝 **原因**: 验证规格完整性，确保满足所有质量标准

---

完美！规格已锁定。

## 规格锁定确认

```
========================================
  规格版本: v0.2
  状态: 待实施
  创建时间: 2024-01-15 10:30:00
========================================
```

**下一步：进入 UltraWork 模式，开始规划**
```

---

# 第二部分：UltraWork 激活与规划

## 🎯 对话轮次 5：UltraWork 激活

### 用户输入

```
ULTRAWORK MODE ENABLED!

请开始实现用户认证 REST API。
规格文件: examples/ultrawork-complete-demo/spec.json
```

### AI 响应（🔍✅ UltraWork 激活确认）

```
🔍 **工具**: `read(filePath="spec.json")`
📝 **原因**: 首先读取规格文件，确保完全理解需求

✅ **工具**: `todowrite(todos=[...])`
📝 **原因**: 创建任务跟踪清单，标记当前状态

🤖 **工具**: `delegate_task(subagent_type="plan")`
📝 **原因**: 调用规划Agent，生成详细任务计划

---

ULTRAWORK MODE ENABLED!

## UltraWork 激活确认

### 规格验证

✅ **Functional (功能)**
- F001: POST /auth/register → 201 + 用户信息
- F002: POST /auth/login → 200 + JWT Token
- F003: POST /auth/refresh → 200 + 新 Token
- F004: GET /auth/me → 200 + 用户详情

✅ **Observable (可观察)**
- O001: HTTP 状态码正确 (2xx/4xx/5xx)
- O002: 响应格式一致 {success, data, error}
- O003: 错误消息可读 (message, code)

✅ **Pass/Fail (通过测试)**
- P001: go build ./... → 退出码 0
- P002: go test ./... → 全部通过
- P003: curl 端点测试 → 全部绿色
- P004: 测试覆盖率 > 80%

✅ **约束条件**
- 安全性: bcrypt 哈希, JWT Secret 从环境变量
- 性能: API 响应 < 200ms
- 代码质量: >80% 覆盖率, 无 any 类型

### 确认理解

我确认理解规格定义：
1. **功能需求**: 实现 4 个 REST API 端点
2. **成功标准**: 所有测试通过，curl 验证成功
3. **约束条件**: 安全性、性能、质量要求
4. **测试计划**: 10 个测试用例

**我已准备好进入规划阶段。**
```

---

## 🎯 对话轮次 6：Plan Agent 规划

### AI 调用 Plan Agent（🤖📋 规划生成）

```
🤖 **工具**: `delegate_task(
  subagent_type="plan",
  prompt="[规格上下文 + 用户需求]",
  run_in_background=false
)`
📝 **原因**: 
   - subagent_type="plan": 使用规划专家Agent
   - 传入完整上下文: 规格、用户需求、技术栈
   - run_in_background=false: 等待结果以便继续

---

## Plan Agent 输出

```json
{
  "session_id": "ses_plan_abc123",
  "waves": [
    {
      "name": "Wave 1: 项目初始化",
      "parallel": false,
      "tasks": [
        {
          "id": "W1-T1",
          "content": "初始化 Go 模块和项目结构",
          "category": "unspecified-low",
          "skills": ["git-master"],
          "dependencies": []
        },
        {
          "id": "W1-T2",
          "content": "创建配置文件和 .env.example",
          "category": "unspecified-low",
          "skills": [],
          "dependencies": ["W1-T1"]
        }
      ]
    },
    {
      "name": "Wave 2: 核心模型和工具",
      "parallel": true,
      "tasks": [
        {
          "id": "W2-T1",
          "content": "定义 User 数据模型",
          "category": "quick",
          "skills": [],
          "dependencies": ["W1-T1"]
        },
        {
          "id": "W2-T2",
          "content": "实现 JWT 工具函数",
          "category": "ultrabrain",
          "skills": [],
          "dependencies": ["W1-T1"]
        },
        {
          "id": "W2-T3",
          "content": "实现密码哈希工具",
          "category": "quick",
          "skills": [],
          "dependencies": ["W1-T1"]
        }
      ]
    },
    {
      "name": "Wave 3: Repository 层",
      "parallel": false,
      "tasks": [
        {
          "id": "W3-T1",
          "content": "实现 User Repository",
          "category": "quick",
          "skills": [],
          "dependencies": ["W2-T1"]
        }
      ]
    },
    {
      "name": "Wave 4: Service 层",
      "parallel": false,
      "tasks": [
        {
          "id": "W4-T1",
          "content": "实现 Auth Service",
          "category": "ultrabrain",
          "skills": [],
          "dependencies": ["W2-T2", "W2-T3", "W3-T1"]
        }
      ]
    },
    {
      "name": "Wave 5: Handler 层",
      "parallel": false,
      "tasks": [
        {
          "id": "W5-T1",
          "content": "实现认证处理器",
          "category": "quick",
          "skills": [],
          "dependencies": ["W4-T1"]
        }
      ]
    },
    {
      "name": "Wave 6: 中间件和路由",
      "parallel": false,
      "tasks": [
        {
          "id": "W6-T1",
          "content": "实现 JWT 认证中间件",
          "category": "quick",
          "skills": [],
          "dependencies": ["W5-T1"]
        },
        {
          "id": "W6-T2",
          "content": "注册路由到主应用",
          "category": "quick",
          "skills": [],
          "dependencies": ["W5-T1", "W6-T1"]
        }
      ]
    },
    {
      "name": "Wave 7: 测试",
      "parallel": false,
      "tasks": [
        {
          "id": "W7-T1",
          "content": "编写单元测试",
          "category": "deep",
          "skills": [],
          "dependencies": ["W6-T2"]
        },
        {
          "id": "W7-T2",
          "content": "编写集成测试",
          "category": "deep",
          "skills": [],
          "dependencies": ["W6-T2"]
        }
      ]
    }
  ],
  "summary": {
    "totalWaves": 7,
    "totalTasks": 12,
    "estimatedLines": "~1060",
    "estimatedDuration": "3-4 小时"
  }
}
```

---

## 对话轮次 7：用户确认执行

### 用户输入

```
是的，开始执行所有任务。
```

### AI 响应（✅ 确认执行）

```
✅ **工具**: `todowrite(todos=[...])`
📝 **原因**: 更新任务状态，标记为进行中

---

好的，开始执行！

## Phase 3: Sisyphus 任务执行

### 执行策略

1. 先执行 Wave 1（串行）
2. 然后执行 Wave 2（并行 3 个任务）
3. 依此类推...
```

---

# 第三部分：实施执行阶段

## 🎯 Wave 1：项目初始化

### W1-T1: 初始化 Go 模块

#### 第一次尝试

```bash
💻 **工具**: `bash(command="go mod init auth-api")`
📝 **原因**: 使用bash执行Go模块初始化命令

# 输出
go: modules disabled in GOPATH; use 'go work' or a directory outside $HOME/src
```

#### 问题诊断

```
🔍 **工具**: `bash(command="go version")`
📝 **原因**: 检查Go版本，诊断环境问题

🔍 **工具**: `bash(command="go env GOPATH GO111MODULE")`
📝 **原因**: 检查环境变量配置

🤖 **工具**: `delegate_task(subagent_type="oracle")`
📝 **原因**: 咨询架构专家，分析Go模块问题
```

#### Oracle 诊断

```
🔮 **工具**: Oracle 输出
📝 **原因**: Oracle是只读顾问，提供架构决策建议

建议方案：
1. 完全禁用 GOPATH
2. 使用 Docker 容器

```bash
export GOPATH=
export GO111MODULE=on
go mod init auth-api
```
```

#### 替代方案执行

```bash
💻 **工具**: `bash(command="cat > go.mod << 'EOF'...")`
📝 **原因**: 手动创建go.mod文件，绕过环境问题

# 输出
✅ go.mod 创建成功
```

#### 验证

```bash
🔍 **工具**: `bash(command="ls -la go.mod")`
📝 **原因**: 验证文件是否存在

✅ **工具**: `todowrite(todos=[{id: "W1-T1", status: "completed"}])`
📝 **原因**: 完成任务，更新状态
```

---

### W1-T2: 创建配置文件

#### 执行

```typescript
📋 **工具**: `delegate_task(
  session_id="ses_plan_abc123",
  category="unspecified-low",
  prompt="创建配置文件...",
  run_in_background=false
)`
📝 **原因**: 
   - session_id: 保持上下文连续性
   - category="unspecified-low": 简单配置任务
   - run_in_background=false: 等待完成
```

#### 写入配置

```go
✍️ **工具**: `write(
  filePath="config/config.go",
  content="package config..."
)`
📝 **原因**: 写入配置文件，包含Config结构体

✍️ **工具**: `write(
  filePath=".env.example",
  content="SERVER_HOST=..."
)`
📝 **原因**: 写入环境变量示例
```

#### 验证

```bash
🔍 **工具**: `bash(command="go vet ./config/...")`
📝 **原因**: 运行静态检查，确保代码质量

✅ **工具**: `todowrite(todos=[{id: "W1-T2", status: "completed"}])`
📝 **原因**: 完成任务
```

---

## 🎯 Wave 2：核心模型和工具（并行执行）

### 并行启动

```typescript
// 💨 **工具**: `⏳ run_in_background=true` × 3
// 📝 **原因**: 3个任务无依赖，并行执行节省时间

💨 const w2t1 = delegate_task(
  session_id="ses_plan_abc123",
  category="quick",
  description="User 数据模型",
  prompt="定义 User 数据模型...",
  run_in_background=true  // 💨 并行执行
)

💨 const w2t2 = delegate_task(
  session_id="ses_plan_abc123",
  category="ultrabrain",
  description="JWT 工具",
  prompt="实现 JWT 工具函数...",
  run_in_background=true  // 💨 并行执行
)

💨 const w2t3 = delegate_task(
  session_id="ses_plan_abc123",
  category="quick",
  description="密码哈希工具",
  prompt="实现密码哈希工具...",
  run_in_background=true  // 💨 并行执行
)

// 📥 **工具**: `background_output(task_id=...)`
// 📝 **原因**: 收集并行任务结果
```

### W2-T1: User 数据模型

```go
✍️ **工具**: `write(
  filePath="models/user.go",
  content="package models..."
)`
📝 **原因**: 写入User数据模型定义
```

### W2-T2: JWT 工具函数

```go
✍️ **工具**: `write(
  filePath="utils/jwt.go",
  content="package utils..."
)`
📝 **原因**: 写入JWT工具实现，包含生成和验证Token

🔍 **工具**: `read(filePath="utils/jwt.go")`
📝 **原因**: 验证JWT代码逻辑
```

### W2-T3: 密码哈希工具

```go
✍️ **工具**: `write(
  filePath="utils/password.go",
  content="package utils..."
)`
📝 **原因**: 写入密码哈希实现，使用bcrypt
```

#### 问题发现

```bash
🔍 **工具**: `bash(command="go vet ./utils/...")`
📝 **原因**: 静态检查发现问题

# 输出
# utils/jwt.go:56:45 - bcrypt should not be used for ID generation
```

#### 问题修复

```typescript
📖 **工具**: `read(filePath="utils/jwt.go")`
📝 **原因**: 读取问题代码位置

✏️ **工具**: `edit(
  filePath="utils/jwt.go",
  oldString="bcrypt.GenerateFromPassword",
  newString="crypto/rand"
)`
📝 **原因**: 修复安全问题，使用正确的随机数生成

🔍 **工具**: `bash(command="go vet ./utils/...")`
📝 **原因**: 重新验证，确保问题已修复
```

---

## 🎯 Wave 3-6：继续执行

### Wave 3: User Repository

```typescript
📋 **工具**: `delegate_task(
  session_id="ses_plan_abc123",
  category="quick",
  description="User Repository",
  prompt="实现 User Repository...",
  run_in_background=false
)`
📝 **原因**: 依赖W2-T1，必须串行执行
```

### Wave 4: Auth Service

```typescript
📋 **工具**: `delegate_task(
  session_id="ses_plan_abc123",
  category="ultrabrain",
  description="Auth Service",
  prompt="实现 Auth Service...",
  run_in_background=false
)`
📝 **原因**: 
   - category="ultrabrain": 复杂业务逻辑
   - 依赖W2-T2, W2-T3, W3-T1
```

### Wave 5: Handler

```typescript
📋 **工具**: `delegate_task(
  session_id="ses_plan_abc123",
  category="quick",
  description="认证处理器",
  prompt="实现认证处理器...",
  run_in_background=false
)`
📝 **原因**: 依赖W4-T1
```

### Wave 6: 中间件和路由

```typescript
📋 **工具**: `delegate_task(
  session_id="ses_plan_abc123",
  category="quick",
  description="JWT 中间件",
  prompt="实现 JWT 认证中间件...",
  run_in_background=false
)`

📋 **工具**: `delegate_task(
  session_id="ses_plan_abc123",
  category="quick",
  description="注册路由",
  prompt="注册路由到主应用...",
  run_in_background=false
)`
📝 **原因**: 依赖W5-T1和W6-T1
```

---

# 第四部分：测试与 Bug 修复

## 🎯 测试执行

### 运行集成测试

```bash
💻 **工具**: `bash(command="./auth-api &")`
📝 **原因**: 启动服务

💻 **工具**: `bash(command="sleep 2")`
📝 **原因**: 等待服务启动

🔍 **工具**: `bash(command="make integration-test")`
📝 **原因**: 运行集成测试套件
```

### 测试结果

```
# 输出
--- FAIL: TestLogin_InvalidPassword
    auth_test.go:89: expected 401, got 500
--- FAIL: TestMe_Unauthorized
    auth_test.go:134: expected 401, got 500
```

---

## 🎯 Ralph Loop：Bug 修复

### Step 1: 回滚

```bash
💻 **工具**: `bash(command="git status")`
📝 **原因**: 查看当前修改状态

💻 **工具**: `bash(command="git stash")`
📝 **原因**: 暂存更改，保留工作现场

💻 **工具**: `bash(command="git checkout HEAD -- .")`
📝 **原因**: 恢复到上一个已知良好状态
```

### Step 2: 分析

```typescript
📖 **工具**: `read(filePath="services/auth.go")`
📝 **原因**: 读取失败的代码，分析根因

📖 **工具**: `read(filePath="middleware/auth.go")`
📝 **原因**: 读取中间件代码，分析错误处理
```

### Step 3: 修复

```bash
💻 **工具**: `bash(command="git stash pop")`
📝 **原因**: 恢复暂存的更改

✏️ **工具**: `edit(
  filePath="services/auth.go",
  oldString="return \"\", \"\", err",
  newString="return \"\", \"\", ErrInvalidCredentials"
)`
📝 **原因**: 修复错误处理，统一错误码

✏️ **工具**: `edit(
  filePath="middleware/auth.go",
  oldString="message: err.Error()",
  newString="code: getErrorCode(err)"
)`
📝 **原因**: 修复中间件，不暴露内部错误详情
```

### Step 4: 重验证

```bash
🔍 **工具**: `bash(command="go test ./tests/... -v -run TestLogin_InvalidPassword")`
📝 **原因**: 重新运行失败的测试

# 输出
--- PASS: TestLogin_InvalidPassword
```

#### Ralph Loop 完成

```
✅ **工具**: `todowrite(todos=[{id: "Ralph-Loop-1", status: "completed"}])`
📝 **原因**: 标记Ralph Loop任务完成
```

---

## 🎯 继续测试

### 运行所有测试

```bash
🔍 **工具**: `bash(command="go test ./... -v")`
📝 **原因**: 运行全部测试用例

🔍 **工具**: `bash(command="go test ./... -coverprofile=coverage.out")`
📝 **原因**: 生成覆盖率报告
```

### curl 端点测试

```bash
💻 **工具**: `bash(command="curl -X POST http://localhost:8080/auth/register...")`
📝 **原因**: 测试用户注册端点

💻 **工具**: `bash(command="curl -X POST http://localhost:8080/auth/login...")`
📝 **原因**: 测试用户登录端点

💻 **工具**: `bash(command="curl -X POST http://localhost:8080/auth/refresh...")`
📝 **原因**: 测试Token刷新端点

💻 **工具**: `bash(command="curl -X GET http://localhost:8080/auth/me...")`
📝 **原因**: 测试获取用户信息端点
```

### 性能测试

```bash
💻 **工具**: `bash(command="for i in {1..10}; do curl...; done")`
📝 **原因**: 执行10次性能测试，统计平均响应时间
```

---

# 第五部分：最终验证

## 🎯 UltraWork 最终验证

### 验证清单

| 验证项 | 工具 | 结果 |
|--------|------|------|
| Functional | 🔍 curl 测试 | 4/4 ✅ |
| Observable | 🔍 状态码检查 | 3/3 ✅ |
| Pass/Fail | 🔍 测试运行 | 6/6 ✅ |
| 覆盖率 | 📊 coverage.out | 87.3% ✅ |
| 性能 | ⏱️ 时间测量 | 40.8ms ✅ |
| 代码质量 | 🔍 go vet | 无错误 ✅ |

### 生成验证报告

```bash
💻 **工具**: `bash(command="cat > VERIFICATION.md << 'EOF'...")`
📝 **原因**: 生成最终验证报告
```

---

## 📊 工具使用统计

### 按阶段统计

| 阶段 | 主要工具 | 使用次数 |
|------|---------|----------|
| 需求澄清 | 🤖 delegate_task (metis/plan) | 4 |
| 规格生成 | ✍️ write | 1 |
| 项目初始化 | 💻 bash, ✍️ write | 8 |
| 核心模型 | ✍️ write, ✏️ edit | 12 |
| 业务逻辑 | ✍️ write | 6 |
| 测试 | 🔍 bash (go test, curl) | 20+ |
| Bug修复 | 💻 git, ✏️ edit | 8 |
| 验证 | 🔍 bash, 📊 coverage | 15+ |

### 按类型统计

| 工具类型 | Emoji | 使用次数 | 占比 |
|----------|-------|----------|------|
| Bash | 💻 | 35+ | 30% |
| Write | ✍️ | 20+ | 17% |
| Edit | ✏️ | 15+ | 13% |
| Read | 📖 | 12+ | 10% |
| Delegate | 📋 | 15+ | 13% |
| Bash (验证) | 🔍 | 20+ | 17% |

---

## 🎯 关键工具使用原则

### 1. 🤖 何时使用 Agent

| 场景 | Agent | 原因 |
|------|-------|------|
| 需求分析 | metis | 需求模糊，需要澄清 |
| 架构规划 | plan | 需要任务分解和依赖分析 |
| 复杂问题 | oracle | 需要专家意见 |
| 代码实现 | category + skills | 领域优化模型 |

### 2. 💻 何时使用 Bash

| 场景 | 原因 |
|------|------|
| 编译 | go build, go vet |
| 测试 | go test, make test |
| Git 操作 | git stash, checkout |
| 服务管理 | ./auth-api & |
| 手动测试 | curl |

### 3. ✍️/✏️ 何时使用文件操作

| 场景 | 工具 | 原因 |
|------|------|------|
| 创建新文件 | write | 生成代码和配置 |
| 修改现有文件 | edit | 修复bug，优化代码 |
| 读取代码 | read | 理解代码逻辑 |

### 4. 📋 何时使用委派

| 场景 | 原因 |
|------|------|
| 复杂任务 | 分解为子任务 |
| 并行执行 | 多个独立任务 |
| 保持上下文 | 使用 session_id |

---

## 📝 工具使用最佳实践

### ✅ 应该做

1. **保持上下文**: 始终传递 session_id
2. **即时更新**: 完成后立即更新 TODO
3. **验证先行**: 每次修改后运行检查
4. **并行优化**: 识别并行机会

### ❌ 不应该做

1. **不要猜测**: 不确定时使用 Agent 咨询
2. **不要跳过**: 不要跳过验证步骤
3. **不要忽视**: 不要忽视错误信息
4. **不要忘记**: 不要忘记更新 TODO

---

**文档版本**: 1.0.0
**创建日期**: 2024-01-15
