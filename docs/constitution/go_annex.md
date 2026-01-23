# 宪法附录: Go 语言实施细则

**适用范围**: 所有 Go 语言后端项目
**对应宪法版本**: 2.0+

本附录定义了 [项目开发宪法](../../constitution.md) 在 Go 语言项目中的具体执行标准。

---

## 1. 简单性原则实施 (Simplicity)
- **1.1 标准库优先**: 在框架约束外，优先使用 Go 标准库 (`stdlib`)。
- **1.2 依赖管理**: 严禁引入未使用的依赖。使用 `go mod tidy` 保持清洁。

## 2. 测试质量实施 (Test Quality)
- **2.1 表格驱动测试**: 单元测试 **必须** 采用 Table-Driven Tests 模式。
- **2.2 框架选择**: 
    - 单元测试: `testing` (标准库) 或 `goconvey` (如果项目已集成)。
    - Mock: 优先使用接口注入，避免复杂的 Mock 框架，除非必要使用 `gomock`。
- **2.3 并发测试**: 涉及并发的代码必须使用 `go test -race` 验证。

## 3. 明确性原则实施 (Clarity)
- **3.1 错误处理 (Error Handling)**:
    - **禁止**: 严禁使用 `_` 忽略 error。
    - **包装**: 错误传递必须使用 `fmt.Errorf("context: %w", err)` 进行包装，保留堆栈或上下文。
    - **Panic**: 严禁在业务逻辑中使用 `panic`，必须返回 error。仅在 `main` 启动阶段允许 panic。
- **3.2 依赖注入**: 所有依赖（DB, Cache, Config）必须通过结构体字段或函数参数传递，严禁使用全局变量。
- **3.3 GoDoc**: 导出的函数和类型必须有符合 Go 官方规范的注释。

## 4. 代码风格与结构 (Style & Structure)
- **4.1 格式化**: 强制使用 `gofumpt` (比 `gofmt` 更严格)。
- **4.2 并发模型**: 
    - 使用 `errgroup` 管理并发任务。
    - 严禁在生产代码中使用 `time.Sleep` (测试除外)。
    - Context 必须作为第一个参数传递，用于超时和取消控制。
- **4.3 命名规范**: 遵循 `Effective Go` 指南。具体类型优于 `any`/`interface{}`。
- **4.4 文件限制**: 
    - 单文件建议 < 200 行。
    - 单函数建议 < 20 行 (不含错误处理)。

## 5. 架构模式 (Architecture)
- **5.1 ETL 模式**: 数据处理遵循 `Query` -> `Clean` -> `Export` 管道。
- **5.2 乐观锁**: 使用 `UpdateRecordIfMatchStatus` 处理并发更新。
- **5.3 实体隔离**: 支持多实体 (`Futunn`, `MooMoo`) 逻辑分离。
