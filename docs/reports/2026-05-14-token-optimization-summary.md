# 2026-05-14 Token Optimization Summary

## 范围

本轮完成 `.trae/specs/reduce-token-usage/` 中 Task1-Task5 的仓库内落地，覆盖：

- 新增 `session_token_observer.py`，建立主链路 token 场景台账、模型/缓存统计、三维排序与 Top3 识别
- Bash `PreToolUse` 接入 RTK 自动重写
- `claudeception-activator` 增加重复提示缓存/去重、滑动窗口历史清理并压缩输出
- 明显轻量命令切到轻量模型：`changelog-generator`、`audit-skills`、`commit-message-generator`
- 第三轮补强 cutover handoff 内容质量，只使用可验证信号增强交接可读性
- 新增可复跑 benchmark / compare 脚本
- 更新任务勾选并执行回归验证

补充材料：

- 真实 Claude Code 脱困案例复盘见 `docs/reports/2026-05-14-claude-code-token-escape-cases.md`

## 方案与取舍

| 场景 | 优化方案 | 预期收益 | 风险 | 回滚方式 | 验证方式 |
| --- | --- | ---: | --- | --- | --- |
| 主链路 token 观测不足 | 新增 `scripts/session_token_observer.py`，基于 `session-eval.sh` 导出结果生成场景台账、模型/缓存统计、三维排序与 Top3 | 为后续优化提供统一基线与可复跑报表 | 仍依赖 `session-eval.sh` 导出的时间顺序进行场景归因 | 保留原导出链路，停用 observer 即可 | `python3 -m unittest tests.test_session_token_observer -v` |
| Bash 工具输出过长 | 在项目级 `.claude/settings.json` 启用 `PreToolUse -> Bash -> .claude/hooks/rtk-rewrite.sh` | 让高噪音 Bash 调用优先走 RTK，减少动态上下文污染 | 本地未安装 `rtk`/`jq` 时只会静默透传 | 删除 `Bash` matcher | 直接调用 Hook，确认 `git status -> rtk git status` |
| `claudeception-activator` 重复弹出大段提示且历史信号持续堆积 | 增加开关、信号缓存、滑动窗口历史清理和 3 行短提示 | 减少重复提醒、历史污染和无效输出 | 缓存 TTL 或窗口过大时会吞掉过近的重复信号 | 删除窗口化缓存逻辑，恢复原输出 | 两次连续运行：首次输出，第二次静默；窗口测试验证仅保留最近 N 条 |
| 简单命令仍使用较重模型 | 只对 3 个低复杂度命令切 `haiku`，并压缩 prompt | 降低固定提示开销和模型成本 | 过度压缩会损伤命令行为清晰度 | 恢复 `model` 与旧 prompt | frontmatter 断言 + 手工阅读 |
| 外部候选工具评估 | 保留 RTK，暂不接入 `caveman` | 避免重复引入另一套压缩链路 | 少一个候选对照样本 | 后续可按同样基准补测 | 在本轮总结中记录结论 |

## RTK / Caveman 评估结论

- `rtk`：仓库已经存在 Hook 脚本和白皮书说明，接入成本最低，可直接复用，适合作为 Bash `PreToolUse` 的默认路径。
- `caveman`：本轮未接入。原因是当前需求聚焦 Claude Code Bash 重写链路，`rtk` 已能覆盖“命令重写 + 输出压缩”的主路径；继续叠加 `caveman` 会增加依赖和排障面，但对当前仓库并没有明确增益。
- 结论：本轮选择 **RTK 保留 + caveman 记录为候选但不启用**。

## Soft Guards

- Design: `docs/superpowers/specs/2026-05-14-soft-token-guards-design.md`
- Validation: `docs/reports/2026-05-14-soft-token-guards-validation.md`
- Scope: Session Cutover Guard、Fan-out Budget Guard、Task-Class Router、Output Budget Templates
- Status: 第一轮保持软治理，只做提醒、建议与输出收口，不做流程硬阻断

## Session Cutover Handoff

- Design: `docs/superpowers/specs/2026-05-14-session-cutover-handoff-design.md`
- Validation: `docs/reports/2026-05-14-session-cutover-handoff-validation.md`
- Scope: 只强化 `Session Cutover Guard`，把“建议切 session”升级为“建议切 session + 自动生成短 handoff”
- Generated Files: `.claude/tmp/session_summary.md`、`.claude/tmp/session_cutover.md`
- Status: 第二轮仍保持软治理，不自动创建新 session，也不自动注入下一会话 prompt

## Cutover Handoff Quality

- Design: `docs/superpowers/specs/2026-05-14-cutover-handoff-quality-design.md`
- Validation: `docs/reports/2026-05-14-session-cutover-handoff-validation.md`
- Scope: 只增强 `session_cutover.md` 中 `Current Task` 与 `Open Issues` 的保守归纳质量
- Signals: recent commit、modified files、未提交改动、无 recent commit、`CUTOVER` 命中
- Status: 第三轮继续保持软治理，不引入模型摘要、不自动推断业务根因、信息不足时回退 `需要人工补充`

## Benchmark

执行命令：

```bash
python3 scripts/token_optimization_benchmark.py
```

结果：

| 场景 | Before Tokens | After Tokens | 降幅 |
| --- | ---: | ---: | ---: |
| `claudeception-activator` | 141 | 47 | 66.7% |
| `changelog-generator` | 475 | 170 | 64.2% |
| `audit-skills` | 281 | 128 | 54.4% |
| `commit-message-generator` | 161 | 125 | 22.4% |
| **整体** | **1058** | **470** | **55.6%** |

- 统计口径：基于 `git show HEAD:` 读取变更前版本，抽取 prompt-bearing 文本后用 4 字符约 1 token 的固定启发式估算。
- 结论：整体降幅 **55.6%**，满足“前后降幅 >= 40%”目标。

## Hook 验证

### Bash `PreToolUse`

执行：

```bash
python3 - <<'PY'
import json, subprocess
payload = json.dumps({"tool_input": {"command": "git status"}})
result = subprocess.run(
    ["bash", ".claude/hooks/rtk-rewrite.sh"],
    input=payload,
    text=True,
    capture_output=True,
    cwd="/Users/joeyzou/Code/OpenSource/learn-claude-code",
)
print(result.stdout)
print(f"exit={result.returncode}")
PY
```

观察到：

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "permissionDecisionReason": "RTK auto-rewrite",
    "updatedInput": {
      "command": "rtk git status"
    }
  }
}
```

### `claudeception-activator`

执行两次：

```bash
ENABLE_SKILL_ARCHITECT_ACTIVATOR=1 bash .claude/scripts/claudeception-activator.sh
ENABLE_SKILL_ARCHITECT_ACTIVATOR=1 bash .claude/scripts/claudeception-activator.sh
```

观察到首次输出 3 行短提示，第二次无重复输出，说明缓存/去重生效；窗口化测试还验证了历史信号会自动裁剪到最近 N 条。

## 场景观测验证

执行：

```bash
python3 -m unittest tests.test_session_token_observer -v
```

验证点：

- 场景按用户提示词切分并汇总 assistant API 调用
- 每个场景输出 `input_tokens`、`output_tokens`、`cache_read_input_tokens`、`cache_creation_input_tokens`、模型列表、调用频次
- 支持按输入 token、输出 token、调用频次三种维度排序，并输出各自 Top3

## 回归验证

执行命令：

```bash
python3 -m unittest tests.test_task2_task5_token_optimization -v
python3 -m unittest tests.test_token_optimization_benchmark -v
python3 -m unittest tests.test_session_token_observer -v
make test
make lint-skills
make check
```

验证目标：

- Hook 配置与 `rtk-rewrite.sh` 行为正确
- activator 开关、缓存、压缩输出正确
- 轻量命令 frontmatter 正确，`review-code` 仍为重模型，`optimize-prompt` 不降级
- benchmark 脚本稳定输出前后对比

## 长期监控建议

- 每次修改 `.claude/commands/*.md` 后运行 `python3 scripts/token_optimization_benchmark.py`，避免 prompt 回弹。
- 把 `scripts/token_optimization_benchmark.py` 输出追加到 PR 描述或 handoff，形成轻量趋势记录。
- 对 `claudeception-activator` 继续观察误抑制率；若真实完成事件被缓存吞掉，可缩短 `CLAUDECEPTION_ACTIVATOR_CACHE_SECONDS`。
- 若后续 Bash 动态输出仍是主要耗点，再补一轮真实会话级 `session-eval.sh + session_token_observer.py` 压测，把 RTK 动态收益纳入同一报表。

## 剩余风险

- 当前 benchmark 统计的是 prompt / 提示文本体积，不是线上真实 API token 账单；真实运行时收益仍会受会话上下文和调用频次影响。
- `rtk` 的返回码语义在非交互调用里并不稳定，本轮已在 Hook 中兼容“有输出但非零码”的情况；后续升级 `rtk` 时应复测。
- `haiku` 适合当前 3 个简单命令，但如果命令职责后续继续膨胀，需要重新评估模型档位。
