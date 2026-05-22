# Claude Config Manager (Skill)

Claude Code 的可视化配置管理器 —— 在浏览器里管理 **Skills / MCP / Hooks**。

本目录是一个 **Claude Code Skill**：解压到 `~/.claude/skills/` 后，Claude 会在你需要时自动启动本地 Web UI（http://localhost:3000）。

---

## 安装

### 前提

- Node.js 18+
- Claude Code 已安装

### 一键安装

```bash
unzip claude-config-manager.zip -d ~/.claude/skills/
```

解压后目录：

```
~/.claude/skills/claude-config-manager/
├── SKILL.md          # Claude 触发说明
├── README.md         # 本文档
├── server.cjs        # 独立服务器（含前端，无需 npm install）
└── test-prompts.json # 触发词样例
```

无需 `npm install`，无需任何配置。

---

## 使用

### 方式 1：让 Claude 自动启动（推荐）

新开一个 Claude Code 会话，直接说：

> 打开 config manager
> 列出我所有的 skills
> 禁用 xxx skill
> 配置 MCP

Claude 会自动启动服务并提示你访问 **http://localhost:3000**。

### 方式 2：手动启动

```bash
node ~/.claude/skills/claude-config-manager/server.cjs &
```

然后浏览器打开 http://localhost:3000。

指定端口：

```bash
PORT=3001 node ~/.claude/skills/claude-config-manager/server.cjs &
```

---

## 功能

| 模块 | 操作 |
|---|---|
| **Skills** | 列出 / 启用 / 禁用 / 删除（USER / PROJECT / PLUGIN 三种作用域） |
| **MCP** | 列出 / 启用 / 禁用 / 删除 MCP servers |
| **Hooks** | 列出 / 启用 / 禁用 / 删除 `.claude/settings.json` 里的 hooks |

启停机制：

- **Skill**：启用 = `SKILL.md`；禁用 = `SKILL.md.disabled`（重命名）
- **MCP**：禁用时从 `mcpServers` 移到 `_disabledMcpServers`
- **Hook**：禁用时 `type` 改为 `disabled_command` + `disabled: true`

---

## REST API

服务器同时暴露 REST API，可脚本化操作：

```bash
# 列出所有 skills
curl -s http://localhost:3000/api/skills | jq '.[].id'

# 禁用 / 启用
curl -X PATCH http://localhost:3000/api/skills/user:darwin-skill/disable
curl -X PATCH http://localhost:3000/api/skills/user:darwin-skill/enable

# 删除
curl -X DELETE http://localhost:3000/api/skills/user:darwin-skill
```

完整端点：

| 资源 | GET | PATCH `/enable` `/disable` | DELETE |
|---|---|---|---|
| `/api/skills` | ✓ | ✓ | ✓（非 plugin） |
| `/api/mcps` | ✓ | ✓ | ✓ |
| `/api/hooks` | ✓ | ✓ | ✓ |
| `/api/config` | ✓ | — | — |

> Skill ID 格式：`scope:name`（scope = `user` / `project` / `plugin`）。
> 名称含 `/` 时需 URL encode。

---

## 排障

**服务器无响应？**

```bash
# 1. 看日志
tail -20 /tmp/ccm.log

# 2. 检查进程
ps aux | grep server.cjs

# 3. 强制重启
kill $(cat /tmp/claude-config-manager.pid) 2>/dev/null
rm -f /tmp/claude-config-manager.pid
node ~/.claude/skills/claude-config-manager/server.cjs >> /tmp/ccm.log 2>&1 &
echo $! > /tmp/claude-config-manager.pid

# 4. 验活
curl -s http://localhost:3000/api/config
```

**端口 3000 被占用？** → `PORT=3001 node server.cjs`

**禁用了但 Claude 还看得到？** → 刷新窗口或重开 Claude Code 会话。Plugin Skills 需等 Claude Code 重载插件。

**目录在但不显示为 Skill？** → 目录内必须有 `SKILL.md` 或 `SKILL.md.disabled`，仅目录名不算。

**删除能恢复吗？** → 不能，物理删除，请谨慎。

---

## 卸载

```bash
rm -rf ~/.claude/skills/claude-config-manager
```

---

## 反馈与源码

源码仓库：见分发者提供的 Git 地址。本 skill 由 `npm run package:skill` 打包生成。
