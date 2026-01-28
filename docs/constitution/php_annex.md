# 宪法附录: PHP 语言实施细则

**适用范围**: PHP 后端项目 (Lumen 5.x / PHP 7.0)
**对应宪法版本**: 2.0+

本附录定义了 [项目开发宪法](../../constitution.md) 在 PHP (Lumen 5.x) 项目中的具体执行标准。必须严格确保代码完全兼容 **PHP 7.0** 版本。

---

## 1. 版本兼容性与环境（PHP 7.0 专项）
- **1.1 严格版本限制**: 
    - 运行环境必须锁定为 **PHP 7.0.x**。
    - **禁止** 使用 PHP 7.1+ 引入的特性，包括但不限于：
        - 可空类型声明 (Nullable Types, e.g., `?string`) [7.1+]。
        - Void 返回类型 (`: void`) [7.1+]。
        - 类常量可见性修饰符 (`public const`) [7.1+]。
        - `iterable` 伪类型 [7.1+]。
        - 多异常捕获 (`catch (Type1 | Type2 $e)`) [7.1+]。
        - `list()` 支持键名 (`list("id" => $id) = $data`) [7.1+]。
- **1.2 允许使用的 PHP 7.0 特性**:
    - 标量类型声明 (`int`, `float`, `string`, `bool`)。
    - 返回类型声明 (`: type`)。
    - 太空船操作符 (`<=>`)。
    - 空合并操作符 (`??`)。
    - 匿名类 (`new class`)。
    - 严格类型声明 `declare(strict_types=1)`。
- **1.3 依赖管理**:
    - `composer.json` 必须明确约束 PHP 版本: `"php": ">=7.0 <7.1"`。
    - 所有第三方库必须验证支持 PHP 7.0。

## 2. 简单性原则实施（简单性）
- **2.1 框架优先**: 充分利用 Lumen 5.x 提供的核心功能 (Middleware, Service Provider, Eloquent)，避免重复造轮子。
- **2.2 依赖管理**: 
    - 必须使用 `Composer` 管理依赖。
    - 严禁手动修改 `vendor` 目录下的任何文件。
    - `composer.lock` 必须提交到版本控制。

## 3. 测试质量实施（测试质量）
- **3.1 框架选择**: 必须使用 `PHPUnit` 进行单元测试。
- **3.2 Mock 策略**: 
    - 使用 `Mockery` 或 PHPUnit 自带的 Mock 功能模拟外部依赖。
    - 单元测试不应依赖真实的数据库连接，集成测试除外。
- **3.3 覆盖率**: 核心 Service 层逻辑必须有测试覆盖。
- **3.4 兼容性验证**:
    - CI 流水线必须包含 PHP 7.0 环境下的测试任务。
    - 建议使用 Docker 容器 (`php:7.0-cli`) 运行测试以确保环境一致性。

## 4. 明确性原则实施（明确性）
- **4.1 错误处理（错误处理）**:
    - **异常**: 业务错误应抛出自定义 Exception (如 `BusinessException`)，由全局 `App\Exceptions\Handler` 统一捕获并格式化响应。
    - **PHP 7.0 Error**: 注意捕获 `Throwable` 接口以同时处理 `Exception` 和 PHP 7.0 引入的 `Error` (如 `TypeError`)。
    - **禁止**: 严禁在业务代码中使用 `die()`, `exit()`, `dd()`, `var_dump()`。
    - **日志**: 使用 `Log::info()`, `Log::error()` 记录日志，错误日志必须包含堆栈信息。
- **4.2 类型声明（类型标注）**: 
    - 必须使用 PHP 7.0 支持的标量类型声明 (`string`, `int`, `bool`, `array`)。
    - 函数参数和返回值应尽可能声明类型。
    - 对于 PHP 7.0 不支持的类型（如 `object`, `void`, `nullable`），**必须** 使用 PHPDoc (`@param`, `@return`) 明确标注，**严禁**使用 PHP 7.1+ 语法。
- **4.3 依赖注入**: 
    - 必须使用 Lumen 服务容器 (Service Container) 进行依赖注入 (Constructor Injection)。
    - 严禁在业务逻辑中使用 `new` 关键字硬编码 Service 或 Repository（DTO/Entity 除外）。

## 5. 代码风格与结构（风格与结构）
- **5.1 格式化**: 严格遵循 PSR-2 编码规范。
- **5.2 命名规范**: 
    - 类名: PascalCase (e.g., `UserController`).
    - 方法/变量: camelCase (e.g., `getUserInfo`).
    - 数据库字段: snake_case (e.g., `user_id`).
- **5.3 数组使用**: 优先使用短数组语法 `[]` 而非 `array()`。

## 6. 架构模式（架构）
- **6.1 分层架构**: 遵循 `Controller` -> `Service` -> `Model` 分层。
    - **Controller**: 仅负责 HTTP 请求验证、参数解析和响应格式化，**不包含业务逻辑**。
    - **Service**: 包含所有业务逻辑，可复用。
    - **Model**: 定义 Eloquent 关联关系和 Scope，不包含复杂业务逻辑。
- **6.2 数据库交互**: 
    - 优先使用 Eloquent ORM。
    - 复杂查询可使用 Query Builder (`DB::table(...)`)。
    - 严禁在 Controller/View 层直接编写 SQL 语句。
- **6.3 辅助函数**: 优先使用 Lumen 内置辅助函数 (如 `config()`, `trans()`, `env()`)。
