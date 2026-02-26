# `.claude/` 目录 Token 效率与架构优化设计

**日期**: 2026-02-26
**状态**: 已批准
**优先级**: 高

---

## 设计目标

1. **降低 Token 消耗** - 减少不必要的内容加载
2. **修复配置问题** - 解决孤儿技能、node_modules 问题
3. **简化架构** - 消除冗余和复杂性
4. **对齐最佳实践** - 符合 Claude Code 官方推荐

---

## 问题分析

### 关键问题

| 问题 | 严重性 | 影响 |
|------|--------|------|
| wechat-draft-sync 包含 node_modules | 🔴 严重 | ~7.9M 空间浪费 |
| wechat-draft-sync 缺少 SKILL.md | 🔴 严重 | 孤儿目录 |
| SessionStart Hook 注入完整技能 | 🟡 中等 | Token 浪费 |
| profiles/go 重复引用 AGENTS.md | 🟢 低 | 轻微冗余 |

### Token 效率分析

```
配置规模估算：
├── Skills:      17 个 × ~200 行 = ~3,500 tokens
├── Commands:    ~375 行 = ~750 tokens
├── Constitution: ~275 行 = ~550 tokens
├── Rules:       ~232 行 = ~460 tokens
├── Agents:      ~132 行 = ~260 tokens
└── Hooks:       每次执行额外开销

SessionStart 每次注入: 完整 using-superpowers 内容
```

---

## 解决方案设计

### 第一部分：问题修复

#### 1.1 清理 wechat-draft-sync
- **决策**: 选项 B - 保留技能但修复结构
- **操作**:
  - 创建 `SKILL.md` 文件
  - 将 `scripts/` 移出 `.claude/` 或添加到 `.gitignore`
  - 删除 `node_modules` 目录
  - 添加 `scripts/.gitignore` 排除 `node_modules`

#### 1.2 修复重复 @ 引用
- **操作**: 移除 `profiles/go/CLAUDE.md` 中的 `@.claude/AGENTS.md`

---

### 第二部分：Token 效率优化

#### 2.1 SessionStart Hook 优化
- **方案**: 改为注入技能路径引用
- **当前**: 每次注入完整技能内容 (~1000+ tokens)
- **优化后**: 注入路径提示 (~50 tokens)
- **节省**: ~95%

**优化前代码片段**:
```bash
using_superpowers_content=$(cat "${PLUGIN_ROOT}/skills/using-superpowers/SKILL.md" ...)
session_context="...${using_superpowers_escaped}..."
```

**优化后**:
```bash
session_context="...SKILL PATH: ${PLUGIN_ROOT}/skills/using-superpowers/SKILL.md..."
```

#### 2.2 UserPromptSubmit Hook 优化
- **当前**: 每条消息都执行检查
- **优化**: 保留但简化逻辑
- **说明**: 该 Hook 功能合理，但可优化执行效率

---

### 第三部分：架构简化

#### 3.1 技能目录审查

**待审查技能**:
- `skill-architect` - 评估是否必需
- `subagent-driven-development` - 与 `dispatching-parallel-agents` 对比
- `planning-with-files` - 与 `writing-plans` 关系

**审查标准** (Constitution Art. 13.1 - Occam's Razor):
- 该技能是否解决了其他技能无法解决的问题？
- 能否通过合并或删除来简化？

#### 3.2 配置层级简化

**当前结构**:
```
CLAUDE.md
└── @.claude/AGENTS.md
    ├── @.claude/constitution/constitution.md
    ├── @.claude/rules/*.md
    └── ...

profiles/go/CLAUDE.md
└── @.claude/AGENTS.md (重复!)
```

**优化后**:
```
CLAUDE.md
└── @.claude/AGENTS.md
    ├── constitution + rules + ...
    └── Go 特定配置整合
```

---

## Constitution Check

*GATE: Must pass before technical design.*

- [x] **Simplicity (Art. 1)**: 删除不必要的 node_modules，简化配置引用
- [x] **Test First (Art. 2)**: 优化后需验证功能正常
- [x] **Clarity (Art. 3)**: 明确的引用路径，无歧义
- [x] **Core Logic (Art. 4)**: Hook 职责清晰分离
- [x] **Security (Art. 11)**: 不影响权限控制

---

## 实施步骤

### Phase 1: 问题修复
1. 删除 `wechat-draft-sync/scripts/node_modules`
2. 创建 `wechat-draft-sync/SKILL.md`
3. 添加 `scripts/.gitignore` 排除 node_modules
4. 移除 `profiles/go/CLAUDE.md` 中的重复引用

### Phase 2: Token 优化
1. 修改 `superpowers-session-start` Hook
2. 测试 SessionStart 输出
3. 验证 AI 能正确读取技能

### Phase 3: 架构审查
1. 分析技能依赖关系
2. 识别可合并/删除的技能
3. 简化配置层级

### Phase 4: 验证
1. Token 使用对比测试
2. Hook 执行时间测量
3. 功能回归测试

---

## 成功标准

1. `.claude/` 目录大小减少 ~7.9M
2. SessionStart Hook Token 消耗减少 >90%
3. 所有现有功能正常工作
4. 无配置错误或警告

---

## 附录

### 参考资料
- Claude Code 官方文档
- Project Constitution: `.claude/constitution/constitution.md`
- Workflow Protocol: `.claude/rules/workflow-protocol.md`
