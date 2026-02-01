# Learn-Claude-Code 插件化改造迁移计划

**目标**: 将基于 `install.sh` 注入模式的当前项目，重构为符合官方规范的 `Claude Code Plugin` 标准包，以支持通过 NPM 或 Git URL 进行标准化分发与安装。

---

## 1. 可行性评估结论
**结论**: **完全可行且成本极低**。
**理由**: 当前项目的核心资产（Agents, Commands, Hooks, Skills）在目录结构和文件格式上已经与官方插件规范（v1.0）**天然同构**。

| 组件 | 当前位置 | 目标插件位置 | 迁移成本 |
| :--- | :--- | :--- | :--- |
| **Agents** | `.claude/agents/*.md` | `agents/*.md` | 零成本移动 |
| **Commands** | `.claude/commands/**/*.md` | `commands/**/*.md` | 零成本移动 |
| **Skills** | `.claude/skills/*` | `skills/*` | 零成本移动 |
| **Hooks** | `.claude/hooks/*` | `hooks/*` | 零成本移动 |
| **配置** | `install.sh` / `settings.json` | `.claude-plugin/plugin.json` | 需转换逻辑 |

---

## 2. 改造路线图 (Roadmap)

### 阶段一：标准结构构建 (POC)
1.  **创建插件根目录**: 新建 `superclaude-plugin/`。
2.  **元数据定义**: 创建 `.claude-plugin/plugin.json`，定义插件名称、版本、权限声明。
3.  **资产迁移**: 将 `.claude/` 下的各子目录映射到插件根目录。

### 阶段二：配置逻辑迁移
原 `install.sh` 中的逻辑需要转换为插件生命周期管理或文档说明：
1.  **环境检查**: 转化为插件的 `pre-install` 检查（如果支持）或 README 前置要求。
2.  **Makefile 智能合并**: 封装为插件自带的一个 Slash Command (如 `/sc:setup-makefile`)，供用户按需调用，而非安装时强制执行。
3.  **依赖安装**: 在 `plugin.json` 中声明 Python 依赖，或提供 `/sc:install-deps` 命令。

### 阶段三：打包与分发
1.  **NPM 打包**: 创建 `package.json`，将插件发布为 NPM 包（推荐企业内部私有源）。
2.  **Git 分发**: 直接通过 Git 仓库地址安装（如 `claude plugin install git+https://...`）。

---

## 3. 插件元数据设计 (plugin.json)

```json
{
  "schema_version": "1.0",
  "name": "fin-claude-plugin",
  "version": "4.2.0",
  "description": "Enterprise-grade development framework for Claude Code, featuring specialized agents and workflows.",
  "permissions": {
    "filesystem": ["read", "write"],
    "network": ["https://api.anthropic.com", "https://api.github.com"],
    "commands": ["git", "make", "go", "python3"]
  },
  "commands": [
    { "name": "sc:design", "description": "Start architectural design workflow", "file": "commands/sc/design.md" },
    { "name": "fin:dev", "description": "TDD development workflow", "file": "commands/fin/dev.md" }
  ],
  "agents": [
    { "name": "architect", "file": "agents/architect.md" },
    { "name": "code-reviewer", "file": "agents/code-reviewer.md" }
  ]
}
```

## 4. 优势分析

1.  **标准化安装**: 用户只需运行 `npm install -g fin-claude-plugin` 或在配置中添加插件引用，无需手动 clone 代码库和运行 shell 脚本。
2.  **版本控制**: 依托 NPM 或 Git Tag 进行版本管理，用户升级更平滑。
3.  **依赖隔离**: 插件内部的 Python 脚本和依赖可以通过相对路径更严谨地管理，不污染用户全局环境。
4.  **即插即用**: 卸载插件即可清除所有功能，不会像 `install.sh` 那样在用户项目中残留文件。

---

## 5. 立即执行计划
我们将立即在当前项目中创建一个 `plugin_dist` 目录，生成标准的插件结构原型，供您验证。
