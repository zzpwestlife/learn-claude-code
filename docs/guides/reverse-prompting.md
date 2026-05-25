# 反向引导（Reverse Prompting）— 使用指南

面向在本仓库使用 Claude Code 的开发者。完整分析与仓库对照见 [研究笔记](../research/2026-05-25-wechat-reverse-prompting.md)。

---

## 什么时候用

| 场景 | 用反向引导 | 用完整 Skill 流程 |
|------|------------|-------------------|
| 中等复杂功能、边界多 | ✅ | 可选 `design-first` |
| 新功能、要进 git 的设计文档 | 可作第一步 | ✅ `brainstorming` → `writing-plans` |
| 难定位的 Bug | ✅ 诊断提问 | ✅ `systematic-debugging` |
| 改一行文案 / 明显 typo | ❌ 过重 | 直接改 |

---

## 魔法句（复制即用）

**基础版**（需求或设计前）：

```text
在开始之前，先列出你需要了解的所有问题，确保完全理解需求。
列完问题之后停下来，等我逐条回答，不要自己假设答案。
```

**Bug 诊断版**：

```text
我遇到一个 bug：[一句话现象]。我不确定根因。
你需要哪些信息才能定位？按重要性排序列出问题，我回答后再分析。不要猜测后直接改代码。
```

**假设暴露版**（方案前，多市场/多租户尤其有用）：

```text
在我确认之前，先列出你在设计时会依赖的所有假设（用户行为、数据存储、验证层级、默认值、地区/货币/时区）。
列完后 STOP，等我确认或纠正，再给出方案。
```

---

## 三个调节旋钮

在魔法句后追加其一或组合：

```text
只问和技术实现直接相关的问题；业务背景见 CLAUDE.md / AGENTS.md。
```

```text
最多问 5 个最关键的问题；其余你可基于已确认假设合理推断。
```

```text
问题按对方案影响排序；若我时间紧，我只回答前 3 个。
```

---

## 与本仓库 Skill 的关系

1. **轻量任务**：只用上文的 Prompt，不必 `/brainstorming`。
2. **要落库、要计划**：问答结束后说「生成需求确认书」，或触发 `design-first` / `brainstorming`；产物写入 `docs/plans/YYYY-MM-DD-<topic>-requirements-ack.md`（[模板](../plans/_templates/requirements-ack.md)）。
3. **长任务中断**：新会话优先粘贴 **需求确认书** +（如有）BDD `.local.md` 状态文件。

---

## 需求确认书

模板：[requirements-ack.md](../plans/_templates/requirements-ack.md)

生成触发句：

```text
基于我的回答，写一份需求确认书：你理解的功能描述、边界条件、已确认假设、明确不在范围内的内容。
我确认后再开始实现。
```

---

## 延伸阅读

- [2026-05-25 微信文章分析](../research/2026-05-25-wechat-reverse-prompting.md)
- [技能索引](../skills/README.md) — `brainstorming`、`design-first`、`systematic-debugging`
