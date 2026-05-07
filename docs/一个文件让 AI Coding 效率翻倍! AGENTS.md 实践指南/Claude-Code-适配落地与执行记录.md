# Claude Code 适配落地与执行记录

## 1. 目标与范围
- 目标: 将《一个文件让 AI Coding 效率翻倍! AGENTS.md 实践指南》的核心方法落地到当前仓库。
- 范围: 仅适配 Claude Code，不做多工具兼容改造。
- 原则: 地图优先、最小改动、可验证闭环。

## 2. 文章核心要点（含引用与解读）
### 2.1 地图而非手册
- 原文引用: “AGENTS.md 的第一原则是渐进式披露--它是一张地图, 不是一本手册。”
- 原文位置: `一个文件让 AI Coding 效率翻倍! AGENTS.md 实践指南.md` 第 103 行。
- 解读: `.claude/AGENTS.md` 只放全局必要信息和硬规则，细节继续放在 `docs/` 与脚本中。

### 2.2 信息放置标准
- 原文引用: “如果 AI 不知道这条信息就会写出错误的代码, 放 AGENTS.md; 如果只是写出不够好的代码, 放详细文档。”
- 原文位置: 原文第 133 行。
- 解读: 仅将会导致“直接错误”的约束写入 `.claude/AGENTS.md`，避免上下文膨胀。

### 2.3 验证闭环
- 原文引用: “改完代码不算完, 跑通接口才算完。”
- 原文位置: 原文第 206 行。
- 解读: 当前项目改造成“改动后必须执行可复用验证命令并记录结果”的闭环。

### 2.4 规则执行力
- 原文引用: “AGENTS.md 中写的规则, 如果没有自动化检查, AI 和人都会违反。”
- 原文位置: 原文第 271 行。
- 解读: 对现有 `make test`、`make lint-skills`、`make check` 进行统一入口化使用，并记录失败处理动作。

### 2.5 Bad Case 驱动迭代
- 原文引用: “不要试图一次写完 AGENTS.md。从实际使用中发现的 bad case 出发。”
- 原文位置: 原文第 453 行。
- 解读: 增加坏例反馈机制，规则和脚本按真实错误迭代，而非一次性写死。

## 3. Claude Code 适配方案（仅本项目）
### 3.1 落地策略
- 保留当前 `CLAUDE.md -> .claude/AGENTS.md` 入口链路。
- 在 `.claude/AGENTS.md` 增补三类最小闭环信息:
  - 任务完成定义（Done Definition）。
  - 验证命令矩阵（统一命令入口）。
  - Bad case 到规则更新的反馈机制。
- 不引入新工具规范，不修改为多 Agent 通用格式。

### 3.2 实施优先级
- P0（立即）: 补齐 `.claude/AGENTS.md` 中的最小闭环条目。
- P1（本周）: 按 bad case 迭代规则，补必要文档链接。
- P2（持续）: 月度复盘规则有效性和命令稳定性。

## 4. 任务拆分与执行清单
| ID | 任务 | 优先级 | 验证标准 | 预期效果指标 | 状态 |
|---|---|---|---|---|---|
| T1 | 产出本落地文档（含引用、策略、清单） | P0 | 文档存在且结构完整 | 新成员可在 10 分钟内理解执行路径 | 已完成 |
| T2 | 更新 `.claude/AGENTS.md` 增加闭环条目 | P0 | 文件含新增章节且内容可执行 | AI 任务完成标准明确，减少返工 | 已完成 |
| T3 | 执行命令验证（`make test` / `make lint-skills` / `make check`） | P0 | 命令可运行并有结果记录 | 验证流程可复用，闭环可落地 | 已完成（含失败项记录） |
| T4 | 复核并形成交付说明 | P1 | 变更与验证结果可追踪 | 可直接纳入团队流程 | 已完成 |

## 5. 执行记录
### 5.1 T1 执行记录
- 动作: 在当前文章目录创建本文档。
- 结果: 完成。

### 5.2 T2 执行记录
- 动作: 更新 `.claude/AGENTS.md`，新增 Claude Code 最小闭环章节。
- 结果: 完成。

### 5.3 T3 执行记录
- 动作: 执行项目验证命令:
  - `make test`
  - `make lint-skills`
  - `make check`
- 结果: 见“6. 验证结果”。

### 5.4 T4 执行记录
- 动作: 汇总改动路径、验证结果和后续建议。
- 结果: 完成。

## 6. 验证结果
- 第一轮结果:
  - `make test`: 失败。输出为 `Ran 0 tests` + `NO TESTS RAN`，随后 `make: *** [test] Error 5`。
  - `make lint-skills`: 成功。`scripts/lint_skills.py` 正常执行，退出码为 0。
  - `make check`: 失败。先通过 `lint-skills`，随后在 `test` 阶段复现 `NO TESTS RAN` 与 `Error 5`。
- 第二轮修复:
  - 新增 `tests/test_password_gen.py`，提供 2 个可执行单元测试（长度校验、边界校验）。
  - `make test`: 成功，`Ran 2 tests ... OK`。
  - `make check`: 成功，`lint-skills` + `Ran 2 tests ... OK`。
- 结论: 当前 `make test` / `make check` 已恢复可通过状态，失败根因已消除。

## 10. 本轮故障修复摘要（make test / make check）
- Root cause: 仓库无 `tests` 目录与测试用例，`python3 -m unittest discover tests` 在 0 测试场景下返回错误码 5，导致 `make test` 与依赖它的 `make check` 失败。
- Fix: 新增 `tests/test_password_gen.py`，覆盖 `scripts.password_gen.generate()` 的核心行为与边界。
- Confirmed:
  - `make test` 输出 `Ran 2 tests ... OK`。
  - `make check` 输出 `Ran 2 tests ... OK`。
- Regression guard: 新增测试文件 `tests/test_password_gen.py` 作为最小回归保护，避免再次出现“无测试导致命令失败”的状态。

## 11. 规范统一更新
- 已将“测试基线守卫”统一写入 `.claude/AGENTS.md` 的 Done Definition:
  - 当出现 `Ran 0 tests` / `NO TESTS RAN` 时，必须先补最小回归测试，再宣告任务完成。

## 7. 可立即应用 vs 长期规划
### 7.1 可立即应用（低复杂度）
- 在 `.claude/AGENTS.md` 固化 Done Definition。
- 固化命令矩阵和失败后处理路径。
- 将 bad case 反馈机制写入流程。

### 7.2 需要长期规划（中复杂度）
- 建立周期化规则复盘（例如每月一次）。
- 对高频 bad case 补脚本化检查，减少人工解释成本。

## 8. 风险与缓解
- 风险: 规则膨胀导致上下文负担上升。
- 缓解: 严格执行“地图而非手册”，细节下沉文档。
- 风险: 命令偶发不稳定导致假阴性失败。
- 缓解: 将失败场景沉淀为 bad case，优先修复脚本稳定性。

## 9. 后续维护建议
- 每次出现 AI 错误，按“错误现象 -> 规则补充 -> 验证命令”三步更新。
- 保持 `.claude/AGENTS.md` 聚焦硬规则，避免写成大全手册。
