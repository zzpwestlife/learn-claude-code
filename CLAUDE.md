# 导入通用的 AI Agent 协作标准 
@AGENTS.md 

# --- 以下是 Claude Code 专属的高级指令 --- 

## Sub-agent 定义 
- **架构设计**: 当需要进行整体架构设计、技术选型或系统分析时，请调用 `architect` sub-agent。
- **代码构建**: 当需要生成新功能、实现复杂逻辑或重构现有代码时，请调用 `code-builder` sub-agent。
- **文档编写**: 当需要编写技术文档、API 说明或补充代码注释时，请调用 `code-scribe` sub-agent。
- **安全审查**: 当需要进行安全漏洞扫描、代码审计或寻求安全修复建议时，请调用 `security-auditor` sub-agent。
- **测试验证**: 当需要编写单元测试、集成测试或验证代码正确性时，请调用 `test-validator` sub-agent。

## Hooks 配置 
(根据项目实际使用的语言，取消对应行的注释)

### Go Projects
- 在每次代码编辑后, 自动运行 `gofmt`。
<!-- - 在每次代码编辑后, 自动运行 `goimports`。 -->

### PHP Projects
- 在每次代码编辑后, 自动运行 `php -l` 进行语法检查。
<!-- - 在每次代码编辑后, 自动运行 `vendor/bin/php-cs-fixer fix`。 -->
