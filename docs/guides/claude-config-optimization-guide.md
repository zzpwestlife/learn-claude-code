# Claude Code 配置优化指南

> **版本**: 1.0
> **日期**: 2026-02-26
> **状态**: 已完成

---

## 1. 概述

### 1.1 优化的必要性

随着项目的成长，`.claude/` 配置目录会逐渐积累各种技能、命令、Agent 和 Hook。如果不进行定期维护，可能会出现以下问题：

- **空间浪费**: 临时文件、依赖包占用大量磁盘空间
- **Token 低效**: 每次会话加载不必要的内容，增加 API 成本
- **架构混乱**: 孤儿文件、重复引用、职责不清
- **维护困难**: 难以定位问题、理解配置加载顺序

### 1.2 Token 成本分析

```
典型配置规模估算：
├── Skills:      17 个 × ~200 行 = ~3,500 tokens
├── Commands:    ~375 行 = ~750 tokens
├── Constitution: ~275 行 = ~550 tokens
├── Rules:       ~232 行 = ~460 tokens
├── Agents:      ~132 行 = ~260 tokens
└── Hooks:       每次执行额外开销

SessionStart Hook 影响:
├── 优化前: 每次注入完整技能内容 (~1000+ tokens)
├── 优化后: 仅注入路径引用 (~50 tokens)
└── 节省: ~95%
```

### 1.3 目标与预期

| 指标 | 优化前 | 优化后 | 提升 |
|------|--------|--------|------|
| SessionStart Hook | ~5000 bytes | ~700 bytes | ~86% |
| .claude/ 目录大小 | ~8.2M | ~596K | ~93% |
| skills/ 目录 | ~7.9M | ~396K | ~95% |

---

## 2. 问题诊断

### 2.1 空间占用问题

#### 症状

```bash
# 检查目录大小
du -sh .claude/
# 输出: 8.2M	.claude/

# 检查子目录分布
du -sh .claude/*/ | sort -hr
# 输出:
# 7.9M	.claude/skills/
# 156K	.claude/commands/
#  68K	.claude/constitution/
# ...
```

#### 根本原因

1. **node_modules 冗余**: 技能脚本包含 npm 依赖
2. **临时文件未清理**: `.claude/tmp/` 累积测试输出
3. **孤儿目录**: 已废弃的技能目录未删除

#### 诊断命令

```bash
# 查找所有 node_modules
find .claude/ -type d -name "node_modules"

# 查找大文件
find .claude/ -type f -size +100k -exec ls -lh {} \;

# 查找孤儿目录（无 SKILL.md 的技能目录）
for dir in .claude/skills/*/; do
  [ ! -f "${dir}SKILL.md" ] && echo "孤儿目录: $dir"
done
```

### 2.2 Token 效率问题

#### 症状

- 每次新会话启动慢
- API 调用 Token 计数异常高
- Context window 快速耗尽

#### 根本原因

**SessionStart Hook 注入完整内容**:

```bash
# 低效做法
using_superpowers_content=$(cat "${PLUGIN_ROOT}/skills/using-superpowers/SKILL.md")
session_context="...${using_superpowers_content}..."
```

这导致每次会话都加载完整的技能内容，即使 AI 可能并不需要立即使用它。

#### Token 消耗测量

```bash
# 测试 Hook 输出大小
.claude/hooks/superpowers-session-start | wc -c
# 优化前: ~5000 bytes
# 优化后: ~700 bytes
```

### 2.3 架构问题

#### 症状

- 配置加载顺序不清晰
- 同一内容在多处定义
- 技能之间职责重叠

#### 诊断方法

**检查循环引用**:

```bash
grep -rh "^@" .claude --include="*.md" | sort | uniq -c | sort -rn
```

**分析技能依赖**:

```bash
for skill in .claude/skills/*/SKILL.md; do
  echo "=== $(basename $(dirname $skill)) ==="
  grep -E "^name:|^description:" "$skill" | head -2
done
```

---

## 3. 优化方案

### 3.1 清理冗余内容

#### 删除 node_modules

```bash
# 1. 确认存在
ls -la .claude/skills/*/scripts/node_modules

# 2. 删除
rm -rf .claude/skills/*/scripts/node_modules

# 3. 验证
ls -la .claude/skills/*/scripts/ | grep node_modules || echo "已删除"
```

#### 添加 .gitignore

```bash
# 为 scripts/ 目录创建 .gitignore
cat > .claude/skills/your-skill/scripts/.gitignore << 'EOF'
# Ignore npm dependencies
node_modules/

# Ignore npm logs
npm-debug.log*
yarn-debug.log*
yarn-error.log*
EOF
```

#### 移除孤儿技能

```bash
# 识别孤儿目录
for dir in .claude/skills/*/; do
  if [ ! -f "${dir}SKILL.md" ]; then
    echo "发现孤儿目录: $dir"
    # 询问是否删除
    read -p "删除 $dir? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      rm -rf "$dir"
      echo "已删除: $dir"
    fi
  fi
done
```

### 3.2 Token 优化

#### Hook 优化策略

**核心原则**: 注入路径引用，而非内容本身。

**优化前**:

```bash
#!/usr/bin/env bash
# SessionStart hook (低效版本)

PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"

# 读取完整技能内容
using_superpowers_content=$(cat "${PLUGIN_ROOT}/skills/using-superpowers/SKILL.md")

# 转义并注入
using_superpowers_escaped=$(escape_for_json "$using_superpowers_content")
session_context="<EXTREMELY_IMPORTANT>\nYou have superpowers.\n\n${using_superpowers_escaped}\n</EXTREMELY_IMPORTANT>"

# 输出 JSON
cat <<EOF
{
  "additional_context": "${session_context}"
}
EOF
```

**优化后**:

```bash
#!/usr/bin/env bash
# SessionStart hook (优化版本)

set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"

# 仅注入路径引用
skill_path="${PLUGIN_ROOT}/skills/using-superpowers/SKILL.md"
session_context="<EXTREMELY_IMPORTANT>\nYou have superpowers.\n\n**Below is the path to your 'using-superpowers' skill:**\n\nSKILL PATH: ${skill_path}\n\nUse the Read tool to load this skill when needed.\n</EXTREMELY_IMPORTANT>"

# 输出 JSON
cat <<EOF
{
  "additional_context": "${session_context}"
}
EOF
```

**效果对比**:

| 项目 | 优化前 | 优化后 | 节省 |
|------|--------|--------|------|
| 输出大小 | ~5000 bytes | ~700 bytes | ~86% |
| Token 消耗 | ~1000 tokens/session | ~50 tokens/session | ~95% |

### 3.3 架构简化

#### 配置层级优化

**问题**: 重复引用 `@.claude/AGENTS.md`

```
CLAUDE.md
└── @.claude/AGENTS.md
    └── constitution + rules + ...

profiles/go/CLAUDE.md
└── @.claude/AGENTS.md  (重复!)
```

**解决方案**: 专用配置分离

```
CLAUDE.md
└── @.claude/AGENTS.md
    └── constitution + rules + ...

profiles/go/CLAUDE.md
└── Go 特定配置 (无重复引用)
```

**profiles/go/CLAUDE.md 示例**:

```markdown
# Go Profile Configuration

<!--
Purpose: Go-specific overrides for this project.
Note: Core configuration is loaded via CLAUDE.md → AGENTS.md
-->

# Go-Specific Guidelines

## Testing
- Use table-driven tests
- Test files should be in the same package with `_test.go` suffix

## Code Style
- Use `gofumpt` for formatting
- Use `goimports` for import management
- No `else` after return in early-return pattern
```

#### 技能架构审查

**审查标准** (Occam's Razor):

1. 该技能是否解决了其他技能无法解决的问题？
2. 能否通过合并或删除来简化？
3. 职责是否单一清晰？

**审查模板**:

| 技能 | 用途 | 状态 | 理由 |
|------|------|------|------|
| skill-a | 功能 A | 保留 | 无重叠 |
| skill-b | 功能 B | 待审查 | 与 skill-c 重叠 |
| skill-c | 功能 B | 合并 | 与 skill-b 合并 |

---

## 4. 实施步骤

### Phase 1: 清理冗余内容

```bash
# Step 1: 删除 node_modules
find .claude/skills/ -type d -name "node_modules" -exec rm -rf {} +

# Step 2: 添加 .gitignore
cat > .claude/skills/your-skill/scripts/.gitignore << 'EOF'
node_modules/
npm-debug.log*
EOF

# Step 3: 移除孤儿目录
for dir in .claude/skills/*/; do
  [ ! -f "${dir}SKILL.md" ] && rm -rf "$dir"
done
```

### Phase 2: Token 优化

```bash
# Step 1: 备份原始 Hook
cp .claude/hooks/superpowers-session-start .claude/hooks/superpowers-session-start.bak

# Step 2: 编辑 Hook (参考 3.2 节代码)
vim .claude/hooks/superpowers-session-start

# Step 3: 测试输出
.claude/hooks/superpowers-session-start | python3 -m json.tool

# Step 4: 清理备份
rm .claude/hooks/superpowers-session-start.bak
```

### Phase 3: 架构简化

```bash
# Step 1: 检查重复引用
grep -rh "@.claude/AGENTS.md" .claude/

# Step 2: 编辑 profile 配置
vim .claude/profiles/go/CLAUDE.md

# Step 3: 验证加载顺序
# (通过新会话测试)
```

### Phase 4: 验证

```bash
# Step 1: 验证目录大小
echo "优化后大小: $(du -sh .claude/ | cut -f1)"

# Step 2: 验证 Hook 功能
.claude/hooks/superpowers-session-start | jq -r '.additional_context' | grep "SKILL PATH"

# Step 3: 验证技能完整性
ls -1 .claude/skills/*/SKILL.md | wc -l

# Step 4: Git 状态
git status
```

---

## 5. 效果对比

### 优化前后数据

| 指标 | 优化前 | 优化后 | 变化 |
|------|--------|--------|------|
| .claude/ 总大小 | 8.2M | 596K | ↓ 93% |
| skills/ 大小 | 7.9M | 396K | ↓ 95% |
| SessionStart Hook | 5000 bytes | 700 bytes | ↓ 86% |
| 技能数量 | 18 (1 孤儿) | 17 | 清理 1 |

### 性能提升

```
Token 消耗减少:
├── SessionStart: ~950 tokens/session 节省
├── 假设 100 sessions/月 = ~95,000 tokens/月
└── 成本节省: ~$1-2/月 (取决于模型)

磁盘空间节省:
├── node_modules: ~7.9M
├── 孤儿目录: ~50K
└── 总计: ~8M
```

### 用户体验改善

- ✅ 新会话启动更快
- ✅ Context window 可用更多
- ✅ 配置更清晰易维护
- ✅ Git clone 更快

---

## 6. 最佳实践

### 6.1 定期检查项

**每月检查**:

```bash
# 1. 目录大小检查
du -sh .claude/ .claude/*/

# 2. node_modules 检查
find .claude/ -type d -name "node_modules"

# 3. 孤儿技能检查
for dir in .claude/skills/*/; do
  [ ! -f "${dir}SKILL.md" ] && echo "孤儿: $dir"
done

# 4. 临时文件检查
ls -la .claude/tmp/
```

### 6.2 禁止模式

❌ **不要**:
- 在 `.claude/skills/` 中运行 `npm install`（不提交 node_modules）
- 在多个文件中重复相同配置
- 创建无 SKILL.md 的技能目录
- 在 Hook 中注入大文件内容

✅ **应该**:
- 使用 `.gitignore` 排除依赖
- 使用 `@file.md` 引用共享内容
- 每个技能都有清晰的 SKILL.md
- Hook 仅注入路径引用

### 6.3 维护建议

1. **技能管理**:
   - 新技能先在 `.claude/skills/` 外测试
   - 验证后再移入正式目录
   - 定期审查重叠技能

2. **Hook 优化**:
   - 遵循 "路径引用 > 内容注入" 原则
   - 测试 Hook 输出大小
   - 使用 `jq` 验证 JSON 格式

3. **版本控制**:
   - 提交前检查 `git status`
   - 使用 `git add` 显式指定文件
   - 避免意外提交临时文件

---

## 7. 附录

### A. 审查报告模板

```markdown
# 技能架构审查报告

**日期**: YYYY-MM-DD
**状态**: 进行中

## 当前技能列表

| 技能 | 用途 | 状态 |
|------|------|------|
| ... | ... | ... |

## 待审查项

### 1. 技能A vs 技能B

**结论**: 保留/合并/删除

**理由**:
- ...

## 审查结论

...

## 优化建议

1. ...
2. ...
```

### B. 验证脚本

```bash
#!/usr/bin/env bash
# verify-claude-config.sh - 配置验证脚本

echo "=== .claude/ 配置验证 ==="

# 1. 目录大小
echo -e "\n1. 目录大小:"
du -sh .claude/ .claude/*/ | sort -hr

# 2. node_modules 检查
echo -e "\n2. node_modules 检查:"
if find .claude/ -type d -name "node_modules" | grep -q .; then
  echo "⚠️  发现 node_modules:"
  find .claude/ -type d -name "node_modules"
else
  echo "✅ 无 node_modules"
fi

# 3. 孤儿技能检查
echo -e "\n3. 孤儿技能检查:"
orphan_found=false
for dir in .claude/skills/*/; do
  if [ ! -f "${dir}SKILL.md" ]; then
    echo "⚠️  孤儿目录: $dir"
    orphan_found=true
  fi
done
if [ "$orphan_found" = false ]; then
  echo "✅ 无孤儿技能"
fi

# 4. Hook 验证
echo -e "\n4. Hook 验证:"
for hook in .claude/hooks/*; do
  if [ -x "$hook" ]; then
    echo "✅ $(basename $hook): 可执行"
  else
    echo "⚠️  $(basename $hook): 不可执行"
  fi
done

# 5. JSON 格式验证
echo -e "\n5. JSON 格式验证:"
for hook in .claude/hooks/*; do
  if "$hook" 2>/dev/null | python3 -m json.tool >/dev/null 2>&1; then
    echo "✅ $(basename $hook): JSON 有效"
  else
    echo "⚠️  $(basename $hook): JSON 无效或无输出"
  fi
done

echo -e "\n=== 验证完成 ==="
```

### C. 回滚方案

**如果优化后出现问题**:

```bash
# 1. 回滚 Hook
cp .claude/hooks/superpowers-session-start.bak .claude/hooks/superpowers-session-start

# 2. 恢复删除的目录
git checkout HEAD -- .claude/skills/removed-skill/

# 3. 恢复配置文件
git checkout HEAD -- .claude/profiles/go/CLAUDE.md

# 4. 完整回滚（如需要）
git reset --hard HEAD
git clean -fd .claude/
```

### D. 参考资源

- **Claude Code 官方文档**: https://docs.anthropic.com/claude-code
- **项目 Constitution**: `.claude/constitution/constitution.md`
- **工作流协议**: `.claude/rules/workflow-protocol.md`
- **原始优化报告**: `.claude/tmp/optimization_summary.md`
- **技能审查报告**: `.claude/tmp/audit_skills.md`

---

## 变更历史

| 版本 | 日期 | 变更 |
|------|------|------|
| 1.0 | 2026-02-26 | 初始版本 |

---

**Contributors**: Joey Zou
**License**: MIT
