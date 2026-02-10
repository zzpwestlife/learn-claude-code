# OpenSpec 工具 vs 轻量级方案对比

## 核心区别

| 维度 | OpenSpec 工具 | 我的 spec.json 方案 |
|------|---------------|-------------------|
| **类型** | 完整命令行工具 | 静态 JSON 文件 |
| **复杂度** | 高（完整工作流） | 低（简单规格定义） |
| **交互性** | 动态提案生成 | 静态文档 |
| **学习成本** | 中等 | 低 |
| **适用场景** | 复杂项目、团队协作 | 简单项目、个人使用 |

---

## OpenSpec 工具概述

### OpenSpec 是什么？

**OpenSpec** 是一个专门为 AI 编码助手设计的**规范驱动开发工具**：

```
官网: https://github.com/Fission-AI/OpenSpec
文档: https://www.aivi.fyi/llms/introduce-OpenSpec
```

### OpenSpec 的核心功能

| 功能 | 描述 |
|------|------|
| `/openspec:proposal` | 动态生成提案（proposal.md） |
| `/openspec:apply` | 按任务清单实现功能 |
| `/openspec:archive` | 归档变更，更新规范 |
| `openspec validate` | 验证提案格式 |
| `openspec view` | 查看提案详情 |

### OpenSpec 的项目结构

```
openspec/
├── AGENTS.md          # OpenSpec 工作流说明
├── project.md         # 项目信息（自动分析生成）
├── specs/             # 规范文档（当前真实状态）
│   ├── timer-session/
│   ├── tree-visualization/
│   └── ...
└── changes/           # 变更提案（进行中的修改）
    └── add-feature/
        ├── proposal.md   # 提案文档（为什么做）
        ├── design.md      # 设计文档（怎么做）
        ├── tasks.md       # 任务清单
        └── specs/         # 规范增量
```

---

## OpenSpec vs 我的方案 对比详解

### 1. 提案生成

#### OpenSpec 工具

```bash
/openspec:proposal Custom Focus Duration
```

AI 会**动态询问关键问题**：
- 时长范围？（1-180分钟？）
- UI 设计？（在哪里选择时长？）
- 统计影响？（如何计算番茄钟？）
- 向后兼容？（旧数据怎么处理？）
- ...

然后生成完整的提案文档：
- `proposal.md` - 动机、影响范围
- `design.md` - 技术决策和理由
- `tasks.md` - 44 个具体任务
- `specs/` - 规范增量

#### 我的 spec.json 方案

用户需要**手动填写**或通过对话收集需求，然后写入 `spec.json`：

```json
{
  "title": "用户认证 REST API",
  "successCriteria": {...},
  "constraints": {...},
  "testPlan": {...}
}
```

**区别**：
- OpenSpec：AI 主动询问，动态生成
- spec.json：用户手动定义，静态文档

---

### 2. 任务分解

#### OpenSpec 工具

自动生成 `tasks.md`：

```markdown
## Tasks: Custom Focus Duration

### Phase 1: 数据模型更新 ✅
- [x] Update FocusSession.swift (durationMinutes)
- [x] Add pomodoroEquivalent computed property

### Phase 2: 时长持久化 ✅
- [x] Create DurationPreference class
- [x] Implement save()/load() methods

### Phase 3: 计时服务增强 ✅
- [x] Update TimerService with sessionDuration
- [x] Implement calculateTreeStage()
```

**特点**：任务分解粒度细，自动标记进度

#### 我的 spec.json 方案

需要 Plan Agent 手动生成 TODO：

```typescript
delegate_task(
  subagent_type="plan",
  prompt="生成任务分解..."
)
// 输出：
// W1-T1: 初始化 Go 模块
// W1-T2: 创建配置文件
// ...
```

**区别**：
- OpenSpec：自动生成，粒度细
- spec.json：需要额外调用 Plan Agent

---

### 3. 规范增量管理

#### OpenSpec 工具

自动生成规范增量，保存在 `changes/.../specs/`：

```
changes/add-custom-focus-duration/
├── proposal.md
├── design.md
├── tasks.md
└── specs/
    ├── timer-session/spec.md
    ├── tree-visualization/spec.md
    └── ...

specs/                    # 归档后的规范
├── timer-session/spec.md
└── ...
```

归档时自动合并：

```bash
openspec archive add-custom-focus-duration
# specs/timer-session/spec.md 更新（合并增量）
```

#### 我的 spec.json 方案

只有一个 `spec.json` 文件，没有增量管理机制。

---

### 4. 工作流程

#### OpenSpec 工具

```
┌─────────────────────────────────────────────┐
│ 1. /openspec:proposal [功能描述]           │
│    AI 询问关键问题 → 生成提案              │
└─────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────┐
│ 2. 审查对齐                                │
│    验证提案 → 调整 → 批准                  │
└─────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────┐
│ 3. /openspec:apply [提案ID]                │
│    按任务清单实现 → 逐个标记完成 ✓         │
└─────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────┐
│ 4. /openspec:archive [提案ID]              │
│    变更归档 → 规范合并 → 历史记录          │
└─────────────────────────────────────────────┘
```

#### 我的 spec.json 方案

```
用户输入需求
    │
    ▼
┌─────────────────────────────────────────────┐
│ 1. 需求澄清（对话）                        │
│    AI 提问 → 用户回答 → 规格定义          │
└─────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────┐
│ 2. 规格验证                                │
│    read(spec.json) → 确认理解              │
└─────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────┐
│ 3. Plan Agent 规划                         │
│    delegate_task(subagent_type="plan")    │
└─────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────┐
│ 4. Sisyphus 执行                           │
│    delegate_task(category="...")          │
└─────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────┐
│ 5. Ralph Loop 质量保障                     │
│    失败 → 回滚 → 修复 → 重验证             │
└─────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────┐
│ 6. UltraWork 最终验证                      │
│    对照 spec.json 逐项检查                 │
└─────────────────────────────────────────────┘
```

---

## 使用场景选择

### 适合使用 OpenSpec 工具的场景

| 场景 | 原因 |
|------|------|
| **复杂项目** | 多模块、多依赖 |
| **团队协作** | 需要清晰的历史记录 |
| **长期维护** | 需要可追溯的变更历史 |
| **AI 助手深度使用** | Cursor、Claude Code 等 |
| **变更频繁** | 功能迭代多，需要增量管理 |

### 适合使用 spec.json 轻量级方案的场景

| 场景 | 原因 |
|------|------|
| **简单项目** | 功能少，需求明确 |
| **快速开发** | 不想花时间学习新工具 |
| **个人项目** | 不需要复杂的版本管理 |
| **学习目的** | 理解规范驱动开发概念 |

---

## OpenSpec 工具安装与使用

### 1. 安装 OpenSpec

```bash
# 检查 Node.js 版本（需要 >= 20.19.0）
node --version
# v22.20.0 ✓

# 全局安装 OpenSpec
npm install -g @fission-ai/openspec@latest
```

### 2. 初始化项目

```bash
# 进入项目目录
cd your-project

# 初始化 OpenSpec
openspec init
```

初始化时会询问：
- 用什么 AI 工具？（Claude Code / Cursor / Codex / ...）
- 是否创建项目信息文件？

### 3. 填充项目信息

让 AI 助手分析项目：

```
Please read openspec/project.md and help me fill it out
with details about my project, tech stack, and conventions
```

### 4. 创建提案

```bash
# 在 Claude Code 中
/openspec:proposal Add User Authentication

# 或使用命令行
openspec proposal "Add User Authentication"
```

AI 会询问关键问题，然后生成完整提案。

### 5. 实施功能

```bash
# 审查通过后，执行实现
/openspec:apply add-user-authentication

# 或使用命令行
openspec apply add-user-authentication
```

### 6. 归档变更

```bash
# 所有测试通过后，归档
/openspec:archive add-user-authentication

# 或使用命令行
openspec archive add-user-authentication --yes
```

---

## OpenSpec 集成到我的工作流

如果要将 OpenSpec 工具集成到 UltraWork + Sisyphus 框架中：

### 集成方案

```
用户输入需求
    │
    ▼
┌─────────────────────────────────────────────┐
│ 1. OpenSpec 提案生成                       │
│    /openspec:proposal [功能]              │
│    生成 proposal.md + design.md + tasks.md │
└─────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────┐
│ 2. 审查对齐                                │
│    对照 proposal.md 确认需求                │
└─────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────┐
│ 3. 提取任务到 TODO                         │
│    读取 tasks.md → 生成 todo list          │
└─────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────┐
│ 4. Sisyphus 执行                           │
│    按任务清单委派 Category Agent           │
└─────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────┐
│ 5. Ralph Loop 质量保障                     │
│    失败 → 回滚 → 修复 → 重验证             │
└─────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────┐
│ 6. UltraWork 最终验证                       │
│    对照 design.md 逐项检查                 │
└─────────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────┐
│ 7. OpenSpec 归档                            │
│    /openspec:archive [提案]                 │
│    规范合并 → 历史记录                      │
└─────────────────────────────────────────────┘
```

---

## OpenSpec 关键命令速查

| 阶段 | 命令 | 描述 |
|------|------|------|
| 安装 | `npm install -g @fission-ai/openspec@latest` | 安装 OpenSpec |
| 初始化 | `openspec init` | 初始化项目 |
| 提案 | `/openspec:proposal [功能]` | 创建提案 |
| 查看 | `openspec view` | 交互式仪表板 |
| 验证 | `openspec validate [提案]` | 验证提案格式 |
| 实施 | `/openspec:apply [提案]` | 执行实现 |
| 归档 | `/openspec:archive [提案]` | 归档变更 |
| 列表 | `openspec list` | 查看活跃提案 |

---

## OpenSpec 优缺点总结

### 优点

| 优点 | 说明 |
|------|------|
| ✅ 动态提案生成 | AI 主动询问，避免遗漏 |
| ✅ 完整历史记录 | 每个变更都有据可查 |
| ✅ 规范增量管理 | 自动合并到主规范 |
| ✅ 工具兼容 | 支持 Claude Code、Cursor 等 |
| ✅ 验证机制 | 内置提案验证 |

### 缺点

| 缺点 | 说明 |
|------|------|
| ❌ 学习成本 | 需要学习新工具的命令 |
| ❌ 额外依赖 | 需要 Node.js 环境 |
| ❌ 流程较重 | 四步流程，小项目可能过度 |
| ❌ 项目结构 | 需要维护 openspec/ 目录 |

---

## 结论

### 选择建议

| 场景 | 推荐方案 |
|------|---------|
| **团队协作、长期项目** | OpenSpec 工具 |
| **复杂功能、多模块** | OpenSpec 工具 |
| **简单项目、快速开发** | spec.json 轻量级方案 |
| **学习规范驱动开发** | spec.json 方案（先入门） |
| **已有 OpenSpec 工作流** | OpenSpec 工具 |

### 我的建议

可以**结合使用**：

1. **小功能** → 使用轻量级 spec.json 方案
2. **大功能** → 使用 OpenSpec 工具
3. **团队项目** → 使用 OpenSpec 工具
4. **个人项目** → 两者皆可

关键是**理解规范驱动开发的核心思想**：**先说清楚做什么，再开始写代码**。

无论选择哪种方案，这个核心原则不变。

---

## 参考资源

- **OpenSpec 官网**: https://github.com/Fission-AI/OpenSpec
- **OpenSpec 文档**: https://www.aivi.fyi/llms/introduce-OpenSpec
- **我的 spec.json 方案**: examples/ultrawork-complete-demo/spec.json
- **完整对话流**: examples/ultrawork-complete-demo/COMPLETE-CONVERSATION-FLOW.md
- **工具使用指南**: examples/ultrawork-complete-demo/TOOL-USAGE-GUIDE.md

---

**文档版本**: 1.0.0
**创建日期**: 2024-01-15
**最后更新**: 2024-01-15
