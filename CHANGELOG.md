# 变更日志 (Changelog)

本文档记录项目的所有重要变更。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

---

## [Unreleased]

### ✨ 新增 (Added)

#### Fibonacci 数列教学项目
- **fib/fibonacci.py** - 新增斐波那契数列实现模块
  - 迭代法实现，时间复杂度 O(n)，空间复杂度 O(1)
  - 完整的类型注解和中文文档字符串
  - 严格的输入验证（类型、范围、布尔值排除）
  - 清晰的错误处理（TypeError, ValueError）

- **fib/test_fibonacci.py** - 新增完整的单元测试套件
  - 10 个测试用例，100% 代码覆盖率
  - 包含基础功能、边界情况、错误处理和递推关系验证
  - 使用 Python 标准库 unittest 框架

- **fib/README.md** - 新增完整的项目文档
  - 项目简介与算法说明
  - 安装和使用指南
  - 测试运行说明
  - 性能数据与最佳实践演示
  - 常见问题解答

- **fib/** 项目文档生态
  - `prompt.md` - 优化后的需求文档
  - `findings.md` - 技术调研与实现分析
  - `task_plan.md` - 4 阶段执行计划
  - `progress.md` - 进度追踪记录
  - `test_results.log` - 测试执行日志

#### 文档
- **CODE_REVIEW.md** - 新增全面的代码审查报告
  - 审查范围：fib 项目 + 仓库配置更新
  - 整体评分：⭐⭐⭐⭐⭐ (5/5)
  - 包含关键问题、改进建议和亮点分析

### 🔧 更新 (Changed)

#### 工作流配置
- **.claude/settings.local.json** - 更新工具权限配置
  - 移除 Go 语言相关工具权限（`gofmt`, `go build`, `go mod init`）
  - 新增 Python 相关工具权限（`python3:*`, `test:*`, `tee:*`, `wc:*`）
  - 移除 PostToolUse hooks 配置（格式化 Go 代码）

- **.claude/commands/optimize-prompt.md** - 工具名称更新
  - `SearchCodebase` → `mgrep`（工具重构）

- **.claude/skills/planning-with-files/SKILL.md** - 工具名称更新
  - `WebFetch` → `webfetch`
  - `WebSearch` → `websearch_web_search_exa`

#### 安装脚本
- **install.sh** - 重大功能增强（向后兼容性需注意）
  - ✨ 新增自动备份机制
    - 替换文件前自动创建带时间戳的备份
  - ✨ 新增交互式配置选择
    - settings.json 冲突时提供 3 个选项（保留/替换/查看差异）
  - ✨ 新增彩色输出和用户友好的进度提示
  - ✨ 新增配置文件安装（changelog_config.json）
  - ✨ 新增 hooks 目录安装
  - 🔧 优化安装流程和错误处理

#### 脚本权限
- 为以下脚本添加可执行权限（chmod +x）：
  - `.claude/skills/changelog-generator/scripts/changelog_agent.py`
  - `.claude/skills/planning-with-files/scripts/init-session.sh`
  - `.claude/skills/review-code/scripts/get-diff.sh`
  - `.claude/skills/review-code/scripts/lint-runner.py`
  - `.claude/skills/review-code/scripts/metadata-checker.py`

### 📝 文档 (Documentation)

- 新增完整的代码审查报告（CODE_REVIEW.md）
- Fibonacci 项目包含 7 份文档，形成完整的知识库
- install.sh 新增安装后使用指南

### ⚠️ 已知问题 (Known Issues)

#### install.sh 自动化兼容性
- **问题**: 新增的交互式用户选择可能阻塞 CI/CD 自动化流程
- **影响**: 无人值守安装脚本需要人工干预
- **临时解决方案**: 无当前解决方案，需要添加 `--non-interactive` 标志
- **建议**: 添加环境变量 `SKIP_INTERACTIVE=true` 支持

#### 工具权限配置
- **问题**: `.claude/settings.local.json` 中的 Bash 通配符权限过于宽泛
  - `Bash(test:*)` 允许任意 `test:` 开头的命令
  - `Bash(python3:*)` 允许任意 python3 命令及参数
- **影响**: 潜在的命令注入风险（仅影响开发环境）
- **建议**: 使用更精确的模式匹配

### 📊 统计数据 (Statistics)

#### 代码变更
- **修改文件**: 9 个
- **新增文件**: 8 个（含 fib/ 目录下的 7 个文件）
- **代码行数**: 170 行 Python 代码
- **测试覆盖率**: 100%（fib 项目）

#### fib 项目
- **核心实现**: 65 行（fibonacci.py）
- **测试代码**: 96 行（test_fibonacci.py）
- **文档**: 197 行（README.md）+ 其他辅助文档
- **测试用例**: 10 个
- **测试执行时间**: < 0.001s

---

## [Previous Versions]

<details>
<summary>历史版本记录（点击展开）</summary>

### 版本历史
暂无历史版本记录 - 这是首次生成的变更日志。

</details>

---

## 分类说明 (Conventional Commits)

本变更日志使用以下分类：

- **✨ 新增 (Added)**: 新功能
- **🔧 更改 (Changed)**: 现有功能的变更
- **🗑️ 废弃 (Deprecated)**: 即将移除的功能
- **❌ 移除 (Removed)**: 已移除的功能
- **🐛 修复 (Fixed)**: Bug 修复
- **🔒 安全 (Security)**: 安全相关的改进
- **📝 文档 (Documentation)**: 文档相关的变更

---

**维护者**: Claude Code Assistant
**最后更新**: 2026-02-19
