# Ralph Loop 失败恢复流程

## Ralph Loop 概述

Ralph Loop 是自参照循环机制，用于：
- **失败时**: 回滚 → 分析根因 → 修复 → 重验证
- **成功时**: 重构 → 回归测试 → 证据归档

---

## Ralph Loop 触发条件

| 触发场景 | 行为 |
|---------|------|
| 测试失败 (RED) | 进入恢复流程 |
| 3 次修复失败 | STOP → 咨询 Oracle |
| 实现与规格不符 | 回滚 → 重对齐 |
| 回归测试失败 | STOP → 修复回归 |
| 编译错误 | 立即修复 |

---

## Ralph Loop 流程图

```
┌─────────────────────────────────────────────────────────────┐
│  检测到失败 (测试失败/编译错误/验证失败)                     │
└─────────────────────────────────┬───────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 1: 回滚 (Rollback)                                    │
│  • git checkout -- <file>                                  │
│  • 恢复到上一个已知良好状态                                  │
└─────────────────────────────────┬───────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 2: 分析根因 (Root Cause Analysis)                     │
│  • 读取错误日志                                             │
│  • 分析失败原因                                             │
│  • 使用 oracle 进行咨询（如需要）                           │
└─────────────────────────────────┬───────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 3: 修复 (Fix)                                         │
│  • 应用最小修复                                             │
│  • 不要重新设计或重写                                       │
└─────────────────────────────────┬───────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 4: 重验证 (Re-verify)                                 │
│  • 重新运行失败的测试                                       │
│  • 确认修复有效                                             │
└─────────────────────────────────┬───────────────────────────┘
                                  │
                    ┌─────────────┴─────────────┐
                    ▼                           ▼
              ┌──────────┐                 ┌──────────┐
              │ 通过?    │                 │ 失败?    │
              └────┬─────┘                 └────┬─────┘
                   │                            │
                   ▼                            ▼
            ┌──────────┐                 ┌──────────┐
            │ 3次失败? │                 │ 重试?    │
            └────┬─────┘                 └────┬─────┘
                 │                            │
           ┌─────┴─────┐               ┌─────┴─────┐
           ▼           ▼               ▼           ▼
      ┌────────┐  ┌────────┐     ┌────────┐  ┌────────┐
      │ 是 →  │  │ 否 →   │     │ 是 →   │  │ 否 →   │
      │ Oracle│  │ 继续   │     │ 重试   │  │ Oracle │
      │ 咨询  │  │ 下一   │     │ Step 3 │  │ 咨询   │
      └────────┘  │ 任务   │     └────────┘  └────────┘
                  └────────┘
```

---

## Ralph Loop 命令模板

### 场景 1: 编译失败

```typescript
// 检测到编译失败
const buildResult = bash(command="go build ./...", description="编译项目")

if (buildResult.exitCode !== 0) {
  // Step 1: 回滚
  bash(command="git status", description="查看修改状态")
  bash(command="git diff --name-only", description="查看修改的文件")

  // 恢复到上一个提交
  bash(command="git stash", description="暂存当前更改")
  bash(command="git checkout HEAD -- .", description="恢复到 HEAD")

  // Step 2: 分析错误
  console.log("编译错误:", buildResult.stderr)

  // Step 3: 修复 (使用 oracle 咨询)
  delegate_task(
    subagent_type="oracle",
    prompt=`编译失败，错误信息: ${buildResult.stderr}
    请分析根因并提供修复建议。`
  )

  // Step 4: 重验证
  bash(command="go build ./...", description="重新编译")
}
```

### 场景 2: 测试失败

```typescript
// 检测到测试失败
const testResult = bash(command="go test ./... -v", description="运行测试")

if (testResult.exitCode !== 0) {
  // Step 1: 回滚
  bash(command="git stash", description="暂存更改")

  // Step 2: 分析
  console.log("测试失败:", testResult.stdout)

  // 分析失败的测试
  const failedTests = extractFailedTests(testResult.stdout)

  failedTests.forEach(test => {
    console.log(`失败测试: ${test.name}`)
    console.log(`错误: ${test.error}`)
  })

  // Step 3: 恢复更改并修复
  bash(command="git stash pop", description="恢复更改")

  // 修复代码
  edit(
    file="src/auth/handler.go",
    oldString="func (h *AuthHandler) Login(c *gin.Context) {",
    newString="func (h *AuthHandler) Login(c *gin.Context) {\n    var req LoginRequest\n    if err := c.ShouldBindJSON(&req); err != nil {\n        c.JSON(400, ErrorResponse{Message: err.Error()})\n        return\n    }"
  )

  // Step 4: 重新测试
  bash(command="go test ./tests/unit/... -v", description="重新运行单元测试")
}
```

### 场景 3: 集成测试失败

```typescript
// 检测到集成测试失败
const integrationResult = bash(
  command="make integration-test",
  description="运行集成测试"
)

if (integrationResult.exitCode !== 0) {
  // Step 1: 回滚
  bash(command="git status", description="查看修改")
  bash(command="git stash", description="暂存更改")

  // 恢复到工作状态
  bash(command="git checkout HEAD -- .", description="恢复文件")

  // Step 2: 分析失败用例
  console.log("失败的测试用例:", integrationResult.stdout)

  // 假设 TC003 失败 (用户登录-密码错误)
  const failedTC = "TC003"

  // Step 3: 恢复并定位问题
  bash(command="git stash pop", description="恢复更改")

  // 查看相关代码
  read(filePath="services/auth.go")

  // 使用 oracle 咨询
  delegate_task(
    subagent_type="oracle",
    prompt=`集成测试 TC003 (用户登录-密码错误) 失败。
    期望: 401 Unauthorized
    实际: 500 Internal Server Error

    请分析 services/auth.go 中的 Login 方法，找出问题所在。`
  )

  // Step 4: 修复
  edit(
    filePath="services/auth.go",
    oldString="// 验证密码\nif err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(input.Password)); err != nil {\n    return \"\", \"\", err\n}",
    newString="// 验证密码\nif err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(input.Password)); err != nil {\n    if err == bcrypt.ErrMismatchedHashAndPassword {\n        return \"\", \"\", errors.New(\"invalid password\")\n    }\n    return \"\", \"\", err\n}"
  )

  // Step 5: 重验证
  bash(command="make integration-test", description="重新运行集成测试")
}
```

---

## Ralph Loop 状态机

```typescript
interface RalphLoopState {
  phase: 'idle' | 'rollback' | 'analyze' | 'fix' | 'verify'
  failureCount: number
  lastError: string
  currentTask: string
}

const ralphLoop = {
  state: {
    phase: 'idle',
    failureCount: 0,
    lastError: '',
    currentTask: ''
  },

  // 进入循环
  enter: (task: string) => {
    ralphLoop.state.currentTask = task
    ralphLoop.state.phase = 'verify'
    ralphLoop.verify()
  },

  // 检测失败
  onFailure: (error: string) => {
    ralphLoop.state.phase = 'rollback'
    ralphLoop.state.lastError = error
    ralphLoop.state.failureCount++
    ralphLoop.rollback()
  },

  // Step 1: 回滚
  rollback: () => {
    console.log(`[Ralph Loop] 回滚: ${ralphLoop.state.currentTask}`)

    // 保存当前状态
    bash(command="git add -A && git stash", description="暂存更改")

    // 恢复到上一次成功状态
    bash(command="git checkout HEAD -- .", description="恢复文件")

    ralphLoop.state.phase = 'analyze'
    ralphLoop.analyze()
  },

  // Step 2: 分析
  analyze: () => {
    console.log(`[Ralph Loop] 分析: ${ralphLoop.state.lastError}`)

    // 检查是否超过最大失败次数
    if (ralphLoop.state.failureCount >= 3) {
      console.log("[Ralph Loop] 超过3次失败，咨询 Oracle")
      ralphLoop.consultOracle()
      return
    }

    ralphLoop.state.phase = 'fix'
    ralphLoop.fix()
  },

  // Step 3: 修复
  fix: () => {
    console.log(`[Ralph Loop] 修复: ${ralphLoop.state.currentTask}`)

    // 恢复更改
    bash(command="git stash pop", description="恢复更改")

    // 应用最小修复
    // ...

    ralphLoop.state.phase = 'verify'
    ralphLoop.verify()
  },

  // Step 4: 验证
  verify: () => {
    console.log(`[Ralph Loop] 验证: ${ralphLoop.state.currentTask}`)

    // 运行验证命令
    const result = bash(command="go test ./... -run TestCurrentTask", description="运行测试")

    if (result.exitCode === 0) {
      console.log("[Ralph Loop] 验证通过!")
      ralphLoop.complete()
    } else {
      ralphLoop.onFailure(result.stderr)
    }
  },

  // 咨询 Oracle
  consultOracle: () => {
    delegate_task(
      subagent_type="oracle",
      prompt=`Ralph Loop 已失败 3 次。
      任务: ${ralphLoop.state.currentTask}
      错误: ${ralphLoop.state.lastError}

      请提供:
      1. 根因分析
      2. 建议的修复方案
      3. 避免类似问题的最佳实践`
    )
  },

  // 完成
  complete: () => {
    ralphLoop.state.phase = 'idle'
    ralphLoop.state.failureCount = 0
    ralphLoop.state.lastError = ''
  }
}
```

---

## Ralph Loop 日志模板

```
=== Ralph Loop Execution Log ===

[TIMESTAMP] Task: W4-T1 (实现 Auth Service)
[TIMESTAMP] Phase: verify
[TIMESTAMP] Command: go test ./services/... -v
[TIMESTAMP] Result: FAIL
[TIMESTAMP] Error: TestLogin_InvalidPassword: expected 401, got 500

[TIMESTAMP] Phase: rollback
[TIMESTAMP] Action: git stash
[TIMESTAMP] Action: git checkout HEAD -- .

[TIMESTAMP] Phase: analyze
[TIMESTAMP] Failure Count: 1/3
[TIMESTAMP] Analysis: 密码验证错误时返回了 500 而非 401

[TIMESTAMP] Phase: fix
[TIMESTAMP] Action: Restored changes
[TIMESTAMP] Action: Applied fix to services/auth.go:45

[TIMESTAMP] Phase: verify
[TIMESTAMP] Command: go test ./services/... -v -run TestLogin
[TIMESTAMP] Result: PASS

=== Ralph Loop Completed Successfully ===
=== Total Time: 2m 34s ===
=== Final Failure Count: 1 ===
```

---

## Ralph Loop 最佳实践

### ✅ 应当做

1. **最小修复**: 只修复失败的部分，不要重写整个模块
2. **立即回滚**: 检测到失败立即回滚，避免污染
3. **计数限制**: 3 次失败后必须咨询 Oracle
4. **记录日志**: 记录每个步骤，便于复盘
5. **保留证据**: 保存错误输出和修复证据

### ❌ 不应当做

1. **不要猜测**: 不要盲目尝试修复
2. **不要跳过**: 不要跳过任何步骤
3. **不要扩大**: 不要借机重构或添加功能
4. **不要隐藏**: 不要隐藏失败或错误
5. **不要放弃**: 3 次失败后咨询 Oracle，不要自己死磕

---

## Ralph Loop 与 TDD 结合

```typescript
// TDD Red-Green-Refactor 循环

// RED: 编写失败的测试
describe("AuthService", () => {
  it("should return 401 for invalid password", async () => {
    const service = new AuthService(mockRepo, mockJWT)
    const result = await service.Login({email: "test@example.com", password: "wrong"})

    // 这个测试会失败，因为还没有实现
    expect(result.error).toBe("invalid_password")
  })
})

// Ralph Loop 检测到 RED
ralphLoop.enter("W4-T1: 实现 Auth Service - 密码验证")

// GREEN: 实现最小代码使测试通过
ralphLoop.onFailure("expected 401, got 500")

// ... Ralph Loop 执行 ...

// 最终: 测试通过
ralphLoop.complete()

// REFACTOR: 重构（如果有需要）
// 注意: Refactor 步骤如果引入新问题，会触发新的 Ralph Loop
```

---

## Ralph Loop 检查清单

在继续下一个任务前，确认以下项目:

- [ ] 所有失败的测试现在通过
- [ ] 编译无错误
- [ ] 无新的 lint 警告
- [ ] 代码变更已保存证据
- [ ] 日志已更新
- [ ] Ralph Loop 完成标记
