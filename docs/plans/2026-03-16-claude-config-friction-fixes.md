# Claude Config Friction Fixes Plan

**Goal:** 修复 Claude Code 配置中的断链引用与易混淆点，减少无效探索与来回追问

**Scope:**
1. 修复/补齐 `.claude/` 配置引用的缺失文件
2. 明确关键入口文件位置（避免重复搜索/误读）
3. 跑通 `make test` 验证不引入回归

**Non-Goals:**
- 不做架构重构
- 不新增复杂规则或依赖

---

## Phase 1: 修复配置摩擦点 (Fixes)

### Task 1: 补齐 lessons 文件

**Files:**
- Create: `.claude/lessons.md`

**Steps:**
1. 创建最小可用的 lessons 模板（记录规则沉淀入口）
2. 保持内容短小，避免会话启动时引入多余上下文

---

### Task 2: 明确 SOUL 位置

**Files:**
- Update: `.claude/AGENTS.md`

**Steps:**
1. 将 `SOUL.md` 的位置明确为仓库根目录，减少路径猜测

---

## Phase 2: 验证 (Verification)

### Task 3: 运行测试

**Steps:**
1. Run: `make test`
2. Expected: 单元测试全部通过

---

## Rollback

- `git checkout -- .claude/AGENTS.md .claude/lessons.md docs/plans/2026-03-16-claude-config-friction-fixes.md`
