# 宪法附录: PHP 语言实施细则

**适用范围**: PHP 后端项目 (Lumen 5.x / PHP 7.0 - 7.1)
**对应宪法版本**: 2.0+

本附录定义了 [项目开发宪法](../../constitution.md) 在 PHP (Lumen 5.x) 项目中的具体执行标准。

---

## 1. 简单性原则实施 (Simplicity)
- **1.1 框架优先**: 充分利用 Lumen 提供的核心功能 (Middleware, Service Provider, Eloquent)，避免重复造轮子。
- **1.2 依赖管理**: 
    - 必须使用 `Composer` 管理依赖。
    - 严禁手动修改 `vendor` 目录下的任何文件。
    - `composer.lock` 必须提交到版本控制。

## 2. 测试质量实施 (Test Quality)
- **2.1 框架选择**: 必须使用 `PHPUnit` 进行单元测试。
- **2.2 Mock 策略**: 
    - 使用 `Mockery` 或 PHPUnit 自带的 Mock 功能模拟外部依赖。
    - 单元测试不应依赖真实的数据库连接，集成测试除外。
- **2.3 覆盖率**: 核心 Service 层逻辑必须有测试覆盖。

## 3. 明确性原则实施 (Clarity)
- **3.1 错误处理 (Error Handling)**:
    - **异常**: 业务错误应抛出自定义 Exception (如 `BusinessException`)，由全局 `App\Exceptions\Handler` 统一捕获并格式化响应。
    - **禁止**: 严禁在业务代码中使用 `die()`, `exit()`, `dd()`, `var_dump()`。
    - **日志**: 使用 `Log::info()`, `Log::error()` 记录日志，错误日志必须包含堆栈信息。
- **3.2 类型声明 (Type Hinting)**: 
    - 尽可能使用 PHP 7.0+ 支持的标量类型声明 (`string`, `int`, `bool`, `array`)。
    - 函数参数和返回值应尽可能声明类型。
    - 对于 PHP 7.0/7.1 不支持的类型（如 `object`, `void`），**必须** 使用 PHPDoc (`@param`, `@return`) 明确标注。
- **3.3 依赖注入**: 
    - 必须使用 Lumen 服务容器 (Service Container) 进行依赖注入 (Constructor Injection)。
    - 严禁在业务逻辑中使用 `new` 关键字硬编码 Service 或 Repository（DTO/Entity 除外）。

## 4. 代码风格与结构 (Style & Structure)
- **4.1 格式化**: 严格遵循 PSR-2 编码规范。
- **4.2 命名规范**: 
    - 类名: PascalCase (e.g., `UserController`).
    - 方法/变量: camelCase (e.g., `getUserInfo`).
    - 数据库字段: snake_case (e.g., `user_id`).
- **4.3 数组使用**: 优先使用短数组语法 `[]` 而非 `array()`。

## 5. 架构模式 (Architecture)
- **5.1 分层架构**: 遵循 `Controller` -> `Service` -> `Model` 分层。
    - **Controller**: 仅负责 HTTP 请求验证、参数解析和响应格式化，**不包含业务逻辑**。
    - **Service**: 包含所有业务逻辑，可复用。
    - **Model**: 定义 Eloquent 关联关系和 Scope，不包含复杂业务逻辑。
- **5.2 数据库交互**: 
    - 优先使用 Eloquent ORM。
    - 复杂查询可使用 Query Builder (`DB::table(...)`)。
    - 严禁在 Controller/View 层直接编写 SQL 语句。
- **5.3 辅助函数**: 优先使用 Lumen 内置辅助函数 (如 `config()`, `trans()`, `env()`)。
