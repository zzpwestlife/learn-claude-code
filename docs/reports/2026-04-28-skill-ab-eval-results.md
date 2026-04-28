# Skills 实测 A/B 评估结果（2026-04-28）

本报告用于把 “dry_run” 的改进，升级为**可复现的实测证据**。  
对照方式：**同一任务跑两遍**（A=with-skill，B=without-skill），在不同分支上从同一 base commit 开始实现。

**Base commit**：`5dffa24742e98b0de22b4f882349dd4493efee98`

---

## 指标说明（轻量）

- **Success**：是否完成（Y/N）
- **Rework count**：因流程/遗漏导致的返工次数（按“需要补救一次”记 1）
- **Completion evidence quality**：
  - 0 = 无证据宣称完成
  - 1 = 有命令但无关键输出
  - 2 = 命令 + exit code + 关键输出（可审计）
- **Notes**：记录“失败模式是否被门控挡住”

---

## Task A（小型 bugfix）：修复 `clean_settings_json.py` 的备份逻辑

**问题定义**：当前脚本会先删除 `hooks`，再写入 `.bak.clean`，导致“备份文件不包含 hooks”。  
**完成定义**：备份包含原始内容（含 hooks）；清理后文件不含 hooks；可复现测试通过。

### A1（with-skill / TDD）：`ab-taskA-with-skill` @ `6260617`

- Success：Y
- Rework count：1（先 RED 再 GREEN）
- Evidence quality：2

**可复现验证：**
```bash
git checkout ab-taskA-with-skill
python3 -m unittest scripts.unit.test_clean_settings_json
```

**证据摘录：**
- RED（预期失败）：`FAILED (failures=1)`（备份缺 hooks）
- GREEN（通过）：`Ran 2 tests ... OK`（exit 0）

### B1（without-skill）：`ab-taskA-without-skill` @ `c1b2502`

- Success：Y
- Rework count：0
- Evidence quality：1（仅跑了命令与 PASS；未按证据模板强制记录 exit+关键行）

**可复现验证：**
```bash
git checkout ab-taskA-without-skill
python3 -m unittest scripts.unit.test_clean_settings_json
```

---

## Task B（中型变更）：新增 Phase 2 汇总生成器 + Makefile 入口

**目标**：从 `.claude/skills/darwin-skill/results.tsv` 生成 markdown 汇总表，并提供 `make phase2-summary` 产出文件。  
**完成定义**：能生成 `docs/reports/phase2-summary.generated.md`；（with-skill 版本）有最小单测覆盖解析/渲染。

### A2（with-skill / TDD + verification）：`ab-taskB-with-skill` @ `fe10451`

- Success：Y
- Rework count：2（先处理 test 文件语法问题 + 模块缺失，再实现通过）
- Evidence quality：2

**可复现验证：**
```bash
git checkout ab-taskB-with-skill
make test
make phase2-summary
```

**证据摘录：**
- `make test`：`Ran 1 test ... OK`（exit 0）
- `make phase2-summary`：生成表头 `| Skill | Baseline | Latest | Δ |`

### B2（without-skill）：`ab-taskB-without-skill` @ `377c86d`

- Success：Y
- Rework count：1（首次运行时因工作区缺失目录导致写文件失败，需恢复目录后重跑）
- Evidence quality：1（有生成物，但无统一“命令+exit+关键输出”格式）

**可复现验证：**
```bash
git checkout ab-taskB-without-skill
make phase2-summary
```

---

## 初步结论

1. **门控价值最明显的地方**：with-skill 流程把“可验证性”前置（RED→GREEN、或命令证据），能更稳定地产生可审计产物。  
2. **without-skill 仍可做对**，但更依赖“习惯与运气”：一旦环境缺失/目录缺失/未记录证据，回溯成本显著上升。  
3. 建议下一轮把 A/B 的任务输入换成“真实 bug + 多文件改动”，并强制用 `verification-before-completion` 的证据块格式记录每一步验证，以便量化 D8（实测）而不是估计。

