# Skill 优化方案（Batch 2）：systematic-debugging

目标：把“最小复现报告模板”升级为强 **R（可复用接口合同）**，并补齐 **Anti-Anchoring**（无 repro/无 logs 必须 STOP、禁止先给修复列表），同时收敛 frontmatter description，降低误触发与 Comprehensive 过载风险。

当前文件：`.claude/skills/systematic-debugging/SKILL.md`

---

## 现状审计结论（简版）

强项：
- 已有强 T：**No-Repro / No-Logs Rule (MANDATORY)**（无法复现且无日志就 STOP）
- 已有最小复现模板（Steps/Expected/Actual/Env/Logs）
- 四阶段流程（Root cause → Pattern → Hypothesis → Implementation）完整

主要改进点（对齐微信文章 S=(C,π,T,R) 与“反锚定”）：
1) **R（可复用接口）不够显式**：模板存在，但缺少“输出合同”与“证据块”，下游复用成本高。  
2) **Anti-Anchoring 缺失**：需要明确禁止：
   - 无复现/无日志情况下输出“修复建议列表”
   - 只给猜测、不给证据链
3) **frontmatter description 偏长**：可压缩到 2-3 行，降低语义噪音。

---

## 章节级别改造方案（最小 diff，避免 Comprehensive 过载）

### 1) Frontmatter：压缩 description（减少误触发）
改成 3 行内：
- 触发：遇到具体失败（错误信息/失败命令/崩溃/回归）
- 硬门槛：无法复现且无 logs/trace → STOP 并索取最小证据
- 输出：必须先产出 **Minimal Repro Report** + **Debugging Evidence Block**

### 2) 新增 “Reusable Interface (R) — Debugging Contract” 小节（放在 Overview 后面）
新增小节内容（固定合同，便于 executing-plans / vbc / CI 复用）：

#### Required Outputs（必须全部具备）
1) **Minimal Repro Report**（MANDATORY）
```
Steps to reproduce:
Expected:
Actual:
Environment (OS/runtime/deps):
Logs / stack trace (full):
```
2) **Debugging Evidence Block**（MANDATORY）
```
Claim: 已完成 Phase <N> / 已定位到 <组件/函数/配置> 是最可能的失败点
Command: <复现命令 / 日志查询命令 / grep 命令>
Exit code: <numeric>
Evidence: <1-3 行关键输出（错误/堆栈/断言失败摘要）>
Next: <下一条最小假设或需要的补充证据>
```

> 注：这是把文章提到的 L1（确定性注入）落地：每一步都有“可验证输入/输出”，而不是抽象讨论。

### 3) 新增 “Anti-Anchoring（反锚定）” 小节（紧跟 R，小而硬）
要点：
- 无 repro 且无 logs → **禁止**提出修复方案（只能索取证据或给最小复现模板）
- 禁止堆“可能原因列表”充数：最多给 2-3 个假设，并且每个必须配“如何验证”的命令
- 示例输出是格式演示，不构成证据；禁止伪造/转述日志

### 4) 在 Phase 1 的 No-Repro/No-Logs 规则下方，增加“最小索取证据清单（按优先级）”
把现有列表改成更“可执行的索取清单”：
1) 失败命令 + stdout/stderr
2) 完整 stacktrace
3) 环境版本 + lockfile
4) last-known-good commit + 当前 commit range

---

## 验证方式（改完后怎么证明有效）

1) 无输入场景：用户只说“有 bug”但没有错误/命令/日志 → skill 必须 STOP 并给出 Minimal Repro Report 模板。  
2) 有输入场景：用户给了失败命令/日志 → 输出中必须出现 Debugging Evidence Block（命令/exit/关键输出）。  

