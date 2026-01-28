# 命令

- **Install**: `pip install -r requirements.txt`
- **Test**: `pytest` (unit tests), `pytest --cov` (coverage)
- **Lint**: `flake8` (linting), `black --check .` (formatting check)
- **Format**: `black .` (code formatting), `isort .` (import sorting)
- **Deps**: `pip freeze > requirements.txt` (update deps)
- **All**: `black . && isort . && flake8 && pytest` (format+lint+test)
*注意：如果缺少 `requirements.txt` 或使用 `poetry`，请查看 `README.md` 获取项目特定命令。*

# 指南

> **⚠️ 宪法**: 本项目严格遵循 [constitution.md](../../constitution.md)。
> 所有代码修改必须符合其 **11 条核心原则** 以及相关 **语言附录**（如 [Python 附录](../../docs/constitution/python_annex.md)）。

## Git 与版本控制
- **提交信息**: **[严格遵循]** Conventional Commits (type(scope): subject)。
  - Format: `<type>(<scope>): <subject>`
  - Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`.
- **原子提交**: 每个提交只包含一个功能或修复。

## 工作流（四阶段）
1. **调研**: 分析上下文与模式。**先审查**：编码前使用 `@` 阅读相关代码并理解既有逻辑。
2. **计划**: 使用下方 **计划模板** 制定步骤化计划。任务复杂时 **等待确认**。包含 **验证步骤**。
3. **实现**: 编写代码与测试。不允许 `TODO`。
4. **验证**: 运行测试与 lint。修复根因，不压制错误。

## 计划模板（强制）
创建计划时，你 **必须** 包含以下 "Constitution Check" 区块：

```markdown
## Constitution Check (合宪性审查)
*GATE: Must pass before technical design.*

- [ ] **Simplicity (Art. 1):** Is the standard library used? Is over-abstraction avoided?
- [ ] **Test First (Art. 2):** Does the plan include writing tests *before* implementation?
- [ ] **Clarity (Art. 3):** Are errors explicitly handled? No global state?
- [ ] **Core Logic (Art. 4):** Is business logic decoupled from HTTP/CLI interfaces?
- [ ] **Security (Art. 11):** Are inputs validated? No sensitive data leakage?

*If any check fails, provide a strong justification in the "Complexity Tracking" section.*
```

## AI 协作指令
- **标准库优先**: 优先使用标准库方案，避免引入新依赖。
- **解释代码**: 对复杂逻辑提供简要的核心设计说明。
- **Pytest Parametrization**: 编写测试时 **必须** 使用 Pytest Parametrization。
- **并发安全**: 明确标识竞态条件，并解释安全措施（Asyncio、Threading Locks）。

## 验证先行
> **"Start with how you'll prove it's right."**
- **代码**: 提供输入/输出示例并通过单元测试。
- **构建**: 修复编译错误并验证可重新构建。
- **重构**: 确保重构前后测试均通过。

## 代码风格与模式
- **核心**: 遵循 [constitution.md](../../constitution.md) 原则。
  - **限制**: 文件 < 200 行，函数 < 20 行，单行 < 80 字符。
  - **变更**: 仅进行最小化差异修改。
- **Python**: 参见 [Python 附录](../../docs/constitution/python_annex.md)（black、isort、PEP 8）。
