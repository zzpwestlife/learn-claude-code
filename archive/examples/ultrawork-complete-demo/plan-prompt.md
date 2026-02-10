# Plan Agent 提示词模板

## 标准 Plan Agent 调用

```markdown
## 任务背景

**项目**: 用户认证 REST API
**规格文件**: examples/ultrawork-complete-demo/spec.json
**语言**: Go 1.21+ / Gin + GORM

## 用户需求

实现完整的用户认证系统，包含:
- POST /auth/register - 用户注册
- POST /auth/login - 用户登录
- POST /auth/refresh - JWT Token 刷新
- GET /auth/me - 获取当前用户信息

## 成功标准 (从 spec.json 提取)

### Functional (功能)
| ID | 端点 | 预期结果 |
|----|------|----------|
| F001 | POST /auth/register | 201, 返回用户信息 |
| F002 | POST /auth/login | 200, 返回 JWT Token |
| F003 | POST /auth/refresh | 200, 返回新 Token |
| F004 | GET /auth/me | 200, 返回用户详情 |

### Observable (可观察)
- HTTP 状态码正确 (2xx/4xx/5xx)
- 响应格式一致: {success, data, error}
- 错误消息包含 code, message, details

### Pass/Fail (通过测试)
- `make test` 退出码 0
- curl 端点测试全部绿色
- lsp_diagnostics 无错误
- go build ./... 编译成功

## 约束条件

### 安全性
- 密码 bcrypt 哈希存储
- JWT Secret 从环境变量读取
- Token 过期时间 ≤ 24小时
- 敏感信息不记录日志

### 性能
- API 响应时间 < 200ms
- 数据库查询 < 50ms
- 支持 100 并发请求

### 代码质量
- 遵循 Go 代码规范
- 单元测试覆盖率 > 80%
- 无 any 类型断言
- 错误处理完整

## 项目结构

```
src/
├── main.go
├── config/
│   └── config.go
├── models/
│   └── user.go
├── handlers/
│   └── auth.go
├── middleware/
│   └── auth.go
├── services/
│   └── auth.go
├── repository/
│   └── user.go
└── utils/
    └── jwt.go
tests/
├── unit/
│   └── auth_test.go
└── integration/
    └── auth_test.go
```

## 请执行以下分析

### 1. 依赖分析

列出实现此功能需要:
- [ ] Go 依赖 (如: gin, gorm, jwt-go, bcrypt)
- [ ] 外部服务 (PostgreSQL, Redis)
- [ ] 数据库表结构
- [ ] 环境变量

### 2. 并行任务分析

识别可以并行执行的任务:
- [ ] API 路由定义
- [ ] 数据模型定义
- [ ] JWT 工具函数
- [ ] 单元测试
- [ ] 集成测试

### 3. 串行任务分析

识别有依赖关系的任务:
- [ ] 配置读取 → JWT 工具 → 服务层 → 处理器 → 路由
- [ ] 数据模型 → Repository → Service → Handler → Route

### 4. 输出 Parallel Task Graph

使用以下格式输出任务图:

```json
{
  "waves": [
    {
      "name": "Wave 1: 基础设施",
      "parallel": true,
      "tasks": [
        {
          "id": "T1.1",
          "name": "创建项目结构和配置文件",
          "file": "config/config.go",
          "category": "unspecified-high",
          "skills": [],
          "dependencies": [],
          "estimatedLines": 100
        }
      ]
    },
    {
      "name": "Wave 2: 核心功能",
      "parallel": false,
      "tasks": [
        {
          "id": "T2.1",
          "name": "实现数据模型",
          "file": "models/user.go",
          "category": "unspecified-low",
          "skills": [],
          "dependencies": ["T1.1"],
          "estimatedLines": 80
        }
      ]
    }
  ],
  "totalTasks": 10,
  "estimatedTotalLines": 500,
  "estimatedDuration": "2-3小时"
}
```

### 5. 输出结构化 TODO 列表

```json
{
  "todos": [
    {
      "id": "T1.1",
      "content": "创建项目结构和配置文件",
      "file": "config/config.go",
      "category": "unspecified-high",
      "skills": ["git-master"],
      "status": "pending",
      "priority": "high",
      "verification": "文件存在且编译通过"
    }
  ]
}
```

### 6. Category + Skills 推荐

对于每个任务，说明为什么选择该 Category 和 Skills:

| 任务 | Category | Skills | 原因 |
|------|----------|--------|------|
| 配置文件 | unspecified-low | - | 简单结构配置 |
| 数据模型 | quick | - | 简单定义 |
| 认证服务 | ultrabrain | - | 复杂业务逻辑 |
| API 处理器 | quick | - | 简单 HTTP 处理 |
| 单元测试 | deep | - | 需要深入测试设计 |

## 输出要求

1. **完整**: 覆盖所有 4 个 API 端点
2. **可执行**: 每个任务都有明确的文件和验收标准
3. **可验证**: 每个任务都有明确的验证方法
4. **优先级清晰**: 按实现顺序排列

请开始分析并生成完整的任务计划。
```

---

## Plan Agent 完整调用命令

```bash
# 在 Claude Code 中调用 Plan Agent
delegate_task(
  subagent_type="plan",
  description="规划用户认证API实现任务",
  prompt="[粘贴上面的完整提示词]",
  run_in_background=false  # 等待结果
)
```

---

## Plan Agent 预期输出示例

```json
{
  "waves": [
    {
      "name": "Wave 1: 项目初始化",
      "parallel": false,
      "tasks": [
        {
          "id": "W1-T1",
          "content": "初始化 Go 模块和项目结构",
          "file": "go.mod",
          "category": "unspecified-low",
          "skills": ["git-master"],
          "dependencies": [],
          "status": "pending",
          "priority": "high"
        },
        {
          "id": "W1-T2",
          "content": "创建配置文件和 .env.example",
          "file": "config/config.go",
          "category": "unspecified-low",
          "skills": [],
          "dependencies": [],
          "status": "pending",
          "priority": "high"
        }
      ]
    },
    {
      "name": "Wave 2: 核心模型和工具",
      "parallel": true,
      "tasks": [
        {
          "id": "W2-T1",
          "content": "定义 User 数据模型和迁移",
          "file": "models/user.go",
          "category": "quick",
          "skills": [],
          "dependencies": ["W1-T1"],
          "status": "pending",
          "priority": "high"
        },
        {
          "id": "W2-T2",
          "content": "实现 JWT 工具函数",
          "file": "utils/jwt.go",
          "category": "ultrabrain",
          "skills": [],
          "dependencies": ["W1-T1"],
          "status": "pending",
          "priority": "high"
        },
        {
          "id": "W2-T3",
          "content": "实现密码哈希工具",
          "file": "utils/password.go",
          "category": "quick",
          "skills": [],
          "dependencies": ["W1-T1"],
          "status": "pending",
          "priority": "medium"
        }
      ]
    },
    {
      "name": "Wave 3: Repository 层",
      "parallel": true,
      "tasks": [
        {
          "id": "W3-T1",
          "content": "实现 User Repository",
          "file": "repository/user.go",
          "category": "quick",
          "skills": [],
          "dependencies": ["W2-T1"],
          "status": "pending",
          "priority": "high"
        }
      ]
    },
    {
      "name": "Wave 4: Service 层",
      "parallel": true,
      "tasks": [
        {
          "id": "W4-T1",
          "content": "实现 Auth Service",
          "file": "services/auth.go",
          "category": "ultrabrain",
          "skills": [],
          "dependencies": ["W2-T2", "W2-T3", "W3-T1"],
          "status": "pending",
          "priority": "high"
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
          "file": "handlers/auth.go",
          "category": "quick",
          "skills": [],
          "dependencies": ["W4-T1"],
          "status": "pending",
          "priority": "high"
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
          "file": "middleware/auth.go",
          "category": "quick",
          "skills": [],
          "dependencies": ["W5-T1"],
          "status": "pending",
          "priority": "high"
        },
        {
          "id": "W6-T2",
          "content": "注册路由",
          "file": "main.go",
          "category": "quick",
          "skills": [],
          "dependencies": ["W5-T1", "W6-T1"],
          "status": "pending",
          "priority": "high"
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
          "file": "tests/unit/auth_test.go",
          "category": "deep",
          "skills": [],
          "dependencies": ["W6-T2"],
          "status": "pending",
          "priority": "high"
        },
        {
          "id": "W7-T2",
          "content": "编写集成测试",
          "file": "tests/integration/auth_test.go",
          "category": "deep",
          "skills": [],
          "dependencies": ["W6-T2"],
          "status": "pending",
          "priority": "high"
        }
      ]
    }
  ],
  "summary": {
    "totalWaves": 7,
    "totalTasks": 15,
    "estimatedLines": 800,
    "estimatedDuration": "3-4小时"
  }
}
```

---

## 会话连续性

Plan Agent 返回的 `session_id` 必须保存，用于后续委派:

```typescript
// 保存 session_id
const planSessionId = "ses_abc123";

// 后续委派时使用
delegate_task(
  session_id=planSessionId,
  category="unspecified-low",
  prompt="执行 W1-T1: 初始化 Go 模块",
  run_in_background=false
)
```
