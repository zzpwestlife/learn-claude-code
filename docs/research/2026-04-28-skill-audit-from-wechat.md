# Skill 审计报告（基于微信文章 + 业界实践启发式）

参考文章：**《Skill 到底能蒸馏我们的几分之几？》**（你提供的 docx）。

审计框架：S=(C, π, T, R) + 文章中提到的风险（Comprehensive 过载、模板锚定、冗余/矛盾扩散指令）。

## 总览表（按风险/缺项排序）

| Skill | Doc | Lines | desc | C | π | T | R | Overload |
|---|---|---:|---:|:---:|:---:|:---:|:---:|:---:|
| ielts | SKILL.md | 193 | 0 | Y | N | Y | Y | N |
| executing-plans | SKILL.md | 103 | 270 | Y | Y | Y | N | N |
| brainstorming | SKILL.md | 196 | 262 | Y | Y | Y | Y | N |
| code-review | SKILL.md | 250 | 249 | Y | Y | Y | Y | N |
| darwin-skill | SKILL.md | 431 | 485 | Y | Y | Y | Y | N |
| design-first | SKILL.md | 316 | 116 | Y | Y | Y | Y | N |
| english-immersion | SKILL.md | 411 | 274 | Y | Y | Y | Y | N |
| systematic-debugging | SKILL.md | 329 | 291 | Y | Y | Y | Y | N |
| test-driven-development | SKILL.md | 395 | 274 | Y | Y | Y | Y | N |
| verification-before-completion | SKILL.md | 176 | 305 | Y | Y | Y | Y | N |
| writing-plans | SKILL.md | 183 | 150 | Y | Y | Y | Y | N |

## 重点发现（Top 5）

### ielts（SKILL.md）
- 路径：`.claude/skills/ielts/SKILL.md`
- 缺少 frontmatter.description（路由与理解成本上升）
- π（执行策略）信号较弱：缺少可执行步骤/检查清单/验证命令

### executing-plans（SKILL.md）
- 路径：`.claude/skills/executing-plans/SKILL.md`
- R（可复用接口）信号较弱：缺少固定输出格式/数据契约/产物说明

### brainstorming（SKILL.md）
- 路径：`.claude/skills/brainstorming/SKILL.md`

### code-review（SKILL.md）
- 路径：`.claude/skills/code-review/SKILL.md`

### darwin-skill（SKILL.md）
- 路径：`.claude/skills/darwin-skill/SKILL.md`
- description 较长（可能触发“Comprehensive 过载/语义近邻冲突”风险，建议压缩到<300~400字符）

## 建议优先改造顺序（第一批 2-3 个）

- **verification-before-completion**：优先补齐缺失的要素（C/π/T/R），并压缩冗余内容，避免 Comprehensive 过载。
- **executing-plans**：优先补齐缺失的要素（C/π/T/R），并压缩冗余内容，避免 Comprehensive 过载。
- **test-driven-development**：优先补齐缺失的要素（C/π/T/R），并压缩冗余内容，避免 Comprehensive 过载。

## 下一步（我建议的执行方式）

1. 对第一批 skill：先做“章节级别改造方案”（不直接大改全文），保证每次改动都是小步可验证。
2. 每个 skill 都补齐：
   - C：误触发降级 / triage（1-3 个判断问题即可）
   - π：最短可复现步骤（MVP）+ 必要示例（避免模板锚定）
   - T：STOP 条件 + 缺信息回退（AskUserQuestion）
   - R：固定输出格式（计划/证据块/报告结构）
3. 改完后再跑一次评估/ratchet（把“dry_run”变成“可复现实测”）。
