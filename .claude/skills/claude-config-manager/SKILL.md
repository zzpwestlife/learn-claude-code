---
name: claude-config-manager
description: 可视化管理 Claude Code 的 Skills / MCP / Hooks 的本地 Web UI，运行在 localhost:3000。Use when the user wants to open config manager, manage skills, enable/disable/delete skills, manage MCP servers, manage hooks, or troubleshoot Claude Code configuration. 触发词：打开 config manager / 管理 skills / 禁用 skill / 配置 MCP / 管理 hooks / open config manager / manage skills
---

# Claude Config Manager

本地 Web UI，可视化管理 Claude Code 配置（Skills / MCP / Hooks）。
服务器是独立的 `server.cjs`，只需 Node.js，无需 `npm install`。

## TL;DR 决策树

```
用户要管理 Claude 配置？
  ├─ 要可视化操作多项 → Step 1-3 启动 UI，打开 localhost:3000
  ├─ 只改单一配置项   → 直接调用 REST API（见下方速查）
  └─ 服务器打不开     → 跳到「排障」章节
```

## 不适用场景

本 skill **不适用**于以下情况，遇到时直接告知用户：
- `server.cjs` 文件不存在 → 需在源码目录执行 `npm run build:standalone && npm run package:skill` 生成 zip 后重新分发
- Node.js 未安装 → 提示用户先安装 Node.js 18+
- 端口 3000 被其他应用占用 → 用 `PORT=3001 node server.cjs` 换端口，或杀掉占用进程
- 用户想编辑 MCP / Hooks 的底层 JSON → 直接编辑 `~/.claude.json` / `~/.claude/settings.json` 更高效

**调用示例（INVOKE）**：
- ✅ "打开 config manager，我要禁用几个 skill" → 调用
- ✅ "帮我管理一下 MCP servers，想删掉几个" → 调用

**跳过示例（SKIP）**：
- ❌ "帮我直接改 ~/.claude.json 里的 MCP 配置" → 跳过，直接编辑 JSON 更高效
- ❌ "解释一下什么是 MCP server" → 跳过，纯问答无需启动 UI

## 使用流程

**Step 1：确认服务器状态**
```bash
PID_FILE=${TMPDIR:-/tmp}/claude-config-manager.pid
if [ -f "$PID_FILE" ] && kill -0 "$(cat $PID_FILE)" 2>/dev/null; then
  echo "Running"
else
  echo "Not running"
fi
```

**Step 2：若未运行，启动服务器**
```bash
SKILL_DIR=~/.claude/skills/claude-config-manager
node "$SKILL_DIR/server.cjs" >> ${TMPDIR:-/tmp}/ccm.log 2>&1 &
echo $! > ${TMPDIR:-/tmp}/claude-config-manager.pid
sleep 1  # 等待启动
```

**Step 3：告知用户打开浏览器**
访问 **http://localhost:3000**

**Step 4（可选）：也可直接通过 API 操作**
如果用户只想做单一操作（如禁用某个 skill），可以跳过 UI，直接调用 REST API。

> ⚠️ **删除操作前须确认**：执行 DELETE 前，先向用户确认 skill/MCP/hook 名称，避免误删。

---

## REST API 速查

### Skills
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/skills` | 列出所有 skills（user / project / plugin） |
| PATCH | `/api/skills/:id/enable` | 启用 |
| PATCH | `/api/skills/:id/disable` | 禁用 |
| DELETE | `/api/skills/:id` | 删除（非 plugin 类） |

**示例：列出所有 skills**
```bash
curl -s http://localhost:3000/api/skills | jq '.[].id'
```

**示例：禁用 darwin-skill**
```bash
curl -X PATCH http://localhost:3000/api/skills/user:darwin-skill/disable
```

**示例：启用 darwin-skill**
```bash
curl -X PATCH http://localhost:3000/api/skills/user:darwin-skill/enable
```

> Skill ID 格式：`scope:name`，scope 可为 `user` / `project` / `plugin`。
> 不确定 ID 时，先用 GET /api/skills 列出，再操作。
> 名称含 `/` 时需 URL encode（如 `user:foo%2Fbar`）。

### MCP Servers
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/mcps` | 列出所有 MCP servers |
| PATCH | `/api/mcps/:id/enable` | 启用 |
| PATCH | `/api/mcps/:id/disable` | 禁用 |
| DELETE | `/api/mcps/:id` | 删除 |

### Hooks
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/hooks` | 列出所有 hooks |
| PATCH | `/api/hooks/:id/enable` | 启用 |
| PATCH | `/api/hooks/:id/disable` | 禁用 |
| DELETE | `/api/hooks/:id` | 删除 |

### Config
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/config` | 获取当前 project root 及路径 |

---

## 排障

如果服务器无响应或无法打开：

**Step 1：检查日志**
```bash
tail -20 ${TMPDIR:-/tmp}/ccm.log
```

**Step 2：检查进程**
```bash
cat ${TMPDIR:-/tmp}/claude-config-manager.pid  # 查看 PID
ps aux | grep server.cjs            # 确认进程存在
```

**Step 3：强制重启**
```bash
kill $(cat ${TMPDIR:-/tmp}/claude-config-manager.pid) 2>/dev/null
rm -f ${TMPDIR:-/tmp}/claude-config-manager.pid
node ~/.claude/skills/claude-config-manager/server.cjs >> ${TMPDIR:-/tmp}/ccm.log 2>&1 &
echo $! > ${TMPDIR:-/tmp}/claude-config-manager.pid
```

**Step 4：确认已启动**
```bash
curl -s http://localhost:3000/api/config
```

---

## 注意

- Plugin-scoped skills 不可通过 API 删除，需卸载插件
- 默认端口 3000；可用 `PORT=xxxx node server.cjs` 覆盖
- 如果 `server.cjs` 不存在，需先在源码目录执行 `npm run build:standalone`
