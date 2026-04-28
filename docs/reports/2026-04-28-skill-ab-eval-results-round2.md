# Skills 实测 A/B 评估结果 Round 2（2026-04-28）

对照方式：**同一任务跑两遍**（A=with-skill，B=without-skill），在不同分支上从同一 base commit 开始实现。

**Base commit**：`9312a99a173b230bd16796be998c409acd8e6794`

---

## Task（真实 bug + 多文件改动）：修复 `/find-skills` 的描述提取与文件兼容

### Bug 现象（可复现）

在 base commit 上运行：

```bash
python3 .claude/scripts/find_skills.py english
```

会出现：
- `english-immersion` 的 `description:` 在 YAML frontmatter 中是未加引号的标量，旧逻辑只匹配 `description: "..."`，因此输出 **No description**
- 部分技能使用 `skill.md` 而非 `SKILL.md`（在大小写敏感环境会被遗漏）

**完成定义**
- 能正确读取 YAML frontmatter（含 `description: |` 多行块、未加引号标量）
- 兼容 `SKILL.md` / `skill.md`
- 变更涉及多文件（脚本 + 解析模块；A 组另含单测）

---

## A 组（with-skill）

**分支**：`ab2-find-skills-with-skill`  
**Commit**：`f37f803`

**改动**：
- 新增 `.claude/scripts/frontmatter.py`（最小 frontmatter 解析器）
- 改造 `.claude/scripts/find_skills.py`：增加 `search_skills()` 便于测试复用；修复 description 提取；兼容 `skill.md`
- 新增 `scripts/unit/test_find_skills.py`（单测覆盖 multiline + lowercase skill.md）

**证据（可复现）**

Claim: 单测通过，且 `find_skills` 能输出 english-immersion 的真实 description  
Command:  
```bash
git checkout ab2-find-skills-with-skill
python3 -m unittest scripts.unit.test_find_skills
python3 .claude/scripts/find_skills.py english | head -n 12
```  
Exit code: 0  
Evidence:
- `Ran 2 tests ... OK`
- 输出中 `english-immersion` 的 `📖` 不再是 `No description`

---

## B 组（without-skill）

**分支**：`ab2-find-skills-without-skill`  
**Commit**：`ac09a63`

**改动**（同一修复目标，但更少门控/证据）：
- 新增 `.claude/scripts/frontmatter.py`
- 修复 `.claude/scripts/find_skills.py` 的 description 提取与文件兼容
- **未增加单测**

**证据（可复现）**

```bash
git checkout ab2-find-skills-without-skill
python3 .claude/scripts/find_skills.py english | head -n 12
```

---

## Round 2 初步结论

1. **with-skill 更“可审计”**：在“真实 bug + 多文件”场景下，A 组天然会产出可复现的测试证据与更清晰的变更边界。  
2. **without-skill 也能修对**，但更容易缺少“回归保护”和统一证据块；后续一旦改动 `find_skills` 或 frontmatter 格式变化，风险更高。  
3. 下一轮建议把任务升级为：涉及 `executing-plans + verification-before-completion` 的“跨脚本/跨目录”变更，并要求每个完成宣称都贴证据块（命令/exit/关键输出）。

