# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- **Skills Workflow**: 优化 `/changelog-generator` 和 `/review-code` 的工作流衔接
  - 改进命令文档，从手动提示改为 `RunCommand` 工具自动触发下一步命令
  - 用户只需确认(Tab/Enter)即可继续，无需手动输入命令
  - 区分 critical issues 和正常流程，优化审查后的 changelog 生成逻辑
- **Hooks**: Claudeception 钩子默认静默模式
  - 通过 `DEBUG=1` 环境变量启用详细输出，减少噪音干扰
  - 符合 Unix "quiet by default" 哲学
- **Planning Skill**: 优化计划状态输出机制
  - 移除冗长的 PreToolUse hooks，避免重复显示计划内容
  - 长输出重定向到项目临时文件 `.claude/tmp/planning_status.md`
  - 使用文件链接形式呈现，保持终端简洁

### Added
- **AGENTS.md**: 新增"简洁输出"指南 (§ 3.4)
  - 要求长输出重定向到项目特定临时 Markdown 文件
  - 规范临时文件路径使用 `.claude/tmp/` 目录
- **.gitignore**: 添加 `.claude/tmp/` 目录，防止临时文件被提交

### Fixed
- **Planning Hook**: 修复临时文件路径，从全局 `/tmp/` 改为项目内 `.claude/tmp/`
  - 避免跨项目污染
  - 提供正确的绝对路径文件链接
