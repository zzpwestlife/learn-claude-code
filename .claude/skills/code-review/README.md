# code-review (Skill)

专业代码审查技能，覆盖三个场景：**执行审查**、**请求审查**、**接收审查**。以高级代码审计师视角，关注正确性、安全性、性能与可维护性。

---

## 触发词

```
代码审查 / review 变更 / 生成 CODE_REVIEW.md / review 这个 PR
```

**前置条件（任一满足）**：
- 已有暂存区变更（`git diff --cached`）
- PR 链接 / commit range / patch 文件 / 指定文件集

无可审查输入时，skill 会停止并请求输入，**不输出泛化建议充数**。

---

## 三种模式

### 一、执行代码审查

1. 自动获取 diff（暂存区 → HEAD → 停止请求输入）
2. 多维度审查：正确性、安全、性能、设计、测试、文档
3. Go 项目额外检查：`defer` 资源泄漏、并发安全、context 传播、`%w` 错误包装
4. 生成 `CODE_REVIEW.md`（严格按 `assets/report-template.md` 模板）
5. 附 **Review Evidence Block**（证明实际读了 diff，非泛化输出）
6. TUI 后续操作：生成 Changelog / 生成修复计划 / 重跑审查

### 二、请求代码审查

在 Subagent 开发流程中，任务完成后调度 `code-reviewer` subagent 进行独立审查。使用 `assets/code-reviewer-prompt.md` 作为 prompt 模板。

### 三、接收代码审查

处理外部审查反馈的标准流程：Read → Understand → Verify → Evaluate → Respond → Implement。

- 禁止表演性赞同（"你完全正确！"）
- 实施前必须验证（不盲目执行）
- 技术正确性 > 舒适度，必要时有理有据地反驳

---

## 输出物

- `CODE_REVIEW.md`：Summary / Critical Issues / Improvement Suggestions / Code Style / Positive Highlights
- Review Evidence Block：证明审查范围与 diff 来源

---

## 辅助工具

| 工具 | 说明 |
|---|---|
| `scripts/get-diff.sh` | 自动选择 staged/unstaged diff |
| `scripts/lint-runner.py` | 按语言执行 go vet / flake8 |
| `references/review-checklist.md` | 审查清单与常见问题 |
| `assets/report-template.md` | CODE_REVIEW.md 模板 |

---

## 不适用场景

- 无 diff、不在 git 仓库、无任何可审查输入 → 停止请求输入
- 用户只需"改一个小问题/格式化/拼写修正" → 直接给最小修改建议，无需走完整流程
