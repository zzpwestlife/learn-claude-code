# 命令

- **Build/Install**: `composer install`
- **Test**: `vendor/bin/phpunit`
- **Lint**: `vendor/bin/phpcs` (if available)
- **Format**: `vendor/bin/php-cs-fixer fix` (if available)
- **Serve**: `php -S localhost:8000 -t public`
*注意：请查看 `composer.json` 的 `scripts` 获取项目特定命令。*

# 指南

> **⚠️ 宪法**: 本项目严格遵循 [constitution.md](../../constitution.md)。
> 所有代码修改必须符合其 **11 条核心原则** 以及相关 **语言附录**（如 [PHP 附录](../../docs/constitution/php_annex.md)）。

## Git 与版本控制
- **提交信息**: **[严格遵循]** Conventional Commits (type(scope): subject)。
  - Format: `<type>(<scope>): <subject>`
  - Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`.

## 工作流（四阶段）
1. **调研**: 分析上下文与模式。**先审查**：编码前使用 `@` 阅读相关代码（Controllers、Services、Models）。
2. **计划**: 使用下方 **计划模板** 制定步骤化计划。**等待确认**。包含 **验证步骤**。
3. **实现**: 编写代码与测试。不允许 `TODO`。
4. **验证**: 运行测试（`phpunit`）与 Lint。修复根因。

## 计划模板（强制）
创建计划时，你 **必须** 包含以下 "Constitution Check" 区块：

```markdown
## Constitution Check (合宪性审查)
*GATE: Must pass before technical design.*

- [ ] **Simplicity (Art. 1):** Is the framework used effectively? Is over-abstraction avoided?
- [ ] **Test First (Art. 2):** Does the plan include writing tests *before* implementation?
- [ ] **Clarity (Art. 3):** Are exceptions explicitly handled? No implicit global state?
- [ ] **Core Logic (Art. 4):** Is business logic in Services, decoupled from Controllers?
- [ ] **Security (Art. 11):** Are inputs validated? No sensitive data leakage?

*If any check fails, provide a strong justification in the "Complexity Tracking" section.*
```

## AI 协作指令
- **框架优先**: 优先使用 Lumen/Laravel 内置能力（Service Container、Eloquent、Middleware），避免自研实现。
- **PSR 合规**: 代码必须遵循 PSR-12 编码规范。
- **依赖注入**: 依赖必须使用构造函数注入。业务逻辑中严禁使用 `new`。
- **类型安全**: 尽可能使用 PHP 7+ 类型标注（标量类型、返回类型）。不支持的类型使用 PHPDoc。

## 验证先行
> **"Start with how you'll prove it's right."**
- **代码**: 提供输入/输出示例并通过单元测试。
- **重构**: 确保重构前后测试均通过。

## 代码风格与模式
- **核心**: 遵循 [constitution.md](../../constitution.md) 原则。
- **PHP**: 参见 [PHP 附录](../../docs/constitution/php_annex.md)。
- **架构**:
  - **Controller**: 只处理请求/响应，不包含业务逻辑。
  - **Service**: 业务逻辑。
  - **Model**: 仅包含 Eloquent 定义。
