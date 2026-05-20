---
name: "add-frpc-tests"
description: "Add unit tests for FRPC Go codebases (gitlab.futunn.com/infra/frpc) to raise coverage. Trigger when user asks 补单测/补充测试用例/提升覆盖率/加测试 for an FRPC repo. SKIP if go.mod lacks frpc dependency."
version: "1.0.0"
tags: ["FRPC", "Golang", "Testing", "Coverage", "Mock"]
categories: ["开发工具", "测试"]
---

# Add FRPC Tests

## 简介
针对**已有 FRPC 代码库**（`gitlab.futunn.com/infra/frpc`，v1.14.2+）的测试用例补充器，目标是**提升覆盖率**。基于既有测试基线做增量：识别未覆盖的函数与分支，复用框架测试基建（`application.Run`、RPC/HTTP/Redis/Kafka/RabbitMQ Mock、Metadata、log/trace），**外科手术式**追加用例，不破坏既有结构。

## 核心约束（不可违反）

| 约束 | 规则 |
|---|---|
| **零改动原则** | 绝不修改任何非 `_test.go` 的生产代码。若覆盖率目标必须依赖重构才能达到，停下来告知用户，说明原因与方案，获得明确同意后才能动产品代码。 |
| **表驱动优先** | 生成的测试必须遵循项目规范。Step 0.5 后立即读 `CLAUDE.md` 检查是否要求 table-driven，若有，则全部测试必须使用 `[]struct{name; ...} + t.Run`，不得用独立 `func Test*`。 |
| **全局状态隔离** | 凡修改包级变量（全局单例、atomic.Pointer 等）的测试，必须用 `t.Cleanup(func(){ ... })` 恢复原值，防止测试间污染。 |
| **预估必须加权** | 承诺覆盖率目标前，必须先扣除不可测文件（`main.go`、依赖外部 SDK 无法注入的文件），用语句数加权计算可达上限，不可凭感觉承诺。 |

## TL;DR — 流程速查
| Step | 输入 | 关键产物 |
|---|---|---|
| 0 前置检测 | `go.mod` | frpc 版本、过/不过 |
| 0.5 TUI 需求采集 + 规范探测 | 用户对话 + CLAUDE.md | 目标包 / 覆盖率目标 / 优先级 / TestMain 策略 / 测试风格规范 |
| 1 覆盖率盘点 + 不可测文件标记 | 目标包 | 未覆盖函数清单 + 不可测文件列表 + 调整后可达上限 |
| 1.5 计划确认 | 函数清单 | 用户签字的待办清单（含加权覆盖率预估） |
| 2 TestMain 决策 | 同包 *_test.go | 不动 / 询问新增 / 跳过 |
| 3 用例生成 | 决策 + reference | 表驱动用例 + mock 注册 |
| 4 验证 | 新文件 | `go test -v` 通过 |
| 5 覆盖率对比 | before/after profile | markdown 表 + 目标达成判定 |

## 适用与不适用
**适用**：项目根 `go.mod` 含 `gitlab.futunn.com/infra/frpc` 且版本 ≥ v1.14.2，业务函数依赖 FRPC 客户端、消息队列消费者、HTTP Client 等。

**不适用 → 主动停止并降级提示**：
- `go.mod` 不含 frpc 依赖 → 提示用户改用 `golang-test-generator` 类通用 skill。
- frpc 版本 < v1.14.2 → 输出 "项目使用 FRPC vX.Y.Z, 本 skill 仅支持 ≥ v1.14.2, 建议升级或人工接入 stub_conf"，停止。
- cgo 代码 / `// Code generated` / `//go:build integration` → 按通用边界拒绝。
- `go env GOMOD` 为空或 `go version` 不可用 → 停止。

## Step 0 — 前置检测（必须先做）
按顺序执行，任一失败立即停止：
1. `cat go.mod` → grep `gitlab.futunn.com/infra/frpc`，命中得到版本号。
2. 解析版本号，确认 ≥ v1.14.2（按 SemVer 比较，主.次.修订）。
3. `go env GOMOD` 非空，`go version` 输出包含 `go1.`。

## Step 0.5 — TUI 需求采集（必须先做，未答完禁止扫描）
在跑覆盖率前，**必须**用 `AskUserQuestion` 收齐 4 项输入。用户未答完任一项 → 停在此步反复追问，不要凭推测进入 Step 1。

| 字段 | 选项（bilingual） | 默认/推荐 |
|---|---|---|
| `target_packages` | 单个包 / 多个包（逗号分隔） / 全仓 `./...` | 单个包 |
| `coverage_goal` | ≥60% / ≥80% / ≥90% / 仅补未覆盖函数（不设阈值） | ≥80% |
| `priority` | happy path 优先 / error 分支优先 / edge case 优先 / 三类均衡 | 三类均衡 |
| `testmain_policy` | 缺失则自动生成 / 缺失则停下询问 / 不动 TestMain | 缺失则停下询问 |

收齐后回显 4 项给用户复核一次（"以下是我理解的需求, 确认无误后进入扫描"），用户改口则更新；用户确认才进入 Step 1。这 4 项后续在 Step 1.5 计划清单里再次显式引用。

**规范探测（与 TUI 同步执行）**：读取 `CLAUDE.md`（或 `.claude/AGENTS.md`），提取测试风格要求。重点检测：
- 是否要求 table-driven tests → 若是，Step 3 全部测试必须使用 `[]struct{name;...}+t.Run`，禁止独立 `func Test*`。
- 最大行数 / 函数长度限制 → 生成时遵守。
- 格式化工具（`gofumpt`/`goimports`）→ 生成后提示用户运行。
记录探测结果，在 Step 1.5 计划清单中声明"将遵循项目 XXX 规范"。

## Step 1 — 覆盖率盘点 + 上下文分析
1. **覆盖率基线**：执行 `go test -cover -coverprofile=/tmp/frpc-cover-before.out ./<目标包>` 获取既有覆盖率与未覆盖行；失败（如包内无测试）则视为 0%，记录 `no_baseline=true`。
2. **基线总数**：`go tool cover -func=/tmp/frpc-cover-before.out | tail -1`（取 `total: (statements) X%`），把这一行**原样回显给用户**（"当前包覆盖率：XX.X%"），让用户对照 `coverage_goal` 判断目标合理性。
3. 解析 `coverprofile`：列出**未覆盖的函数**与**部分覆盖的分支**。一行命令取 <100% 函数清单：`go tool cover -func=/tmp/frpc-cover-before.out | awk '$3 != "100.0%"'`（最后一行 total 忽略）。
4. **不可测文件标记（必做）**：逐一审查 0% 函数所在文件，判断是否属于以下不可测类别并打标：
   - `main()` / `init()` 入口 → 标记 `[SKIP: entrypoint]`
   - 依赖 `application.Run` 的 bootstrap → 标记 `[SKIP: frpc-infra]`
   - 依赖外部 SDK（FCC、OSS、外部 RPC）且无法注入 mock → 标记 `[SKIP: external-sdk]`
   - `// Code generated` 文件 → 标记 `[SKIP: generated]`

   用打标结果计算**加权可达上限**：
   ```
   可达上限 = 1 - (skip_statements / total_statements)
   ```
   若 `coverage_goal` 超过可达上限，在 Step 1.5 中提前警告用户并建议调低目标。
5. Read 目标文件，对未覆盖函数列出入参/返回值与可能错误分支。
5. 静态扫描函数体内的 import 与调用，识别**外部依赖类别**（仅出现以下类别才需对应 mock）：

| 信号 | 依赖类别 | 待加载 reference |
|---|---|---|
| 调用 `*Client.XXX(ctx, req)` 形如 RPC | RPC | `references/rpc-mock.md` |
| `gitlab.futunn.com/infra/frpc/pkg/http` 或硬编码外部 URL | HTTP | `references/http-mock.md` |
| `redis.UniversalClient` / `distributedlock` | Redis | `references/redis-mock.md` |
| `sarama.ConsumerGroupSession` / `kafka.ConsumerMessage` | Kafka | `references/kafka-mock.md` |
| `amqp.Delivery` / `Acknowledger` | RabbitMQ | `references/rmq-mock.md` |
| `metadata.FromIncomingContext` / `srpc.CRpcHead` / 链路追踪 | Metadata/Trace | `references/metadata-and-trace.md` |

6. 同包扫描：`ls` 同目录 `*_test.go`，记录已存在的 TestMain 与已覆盖函数（与覆盖率清单交叉验证）。
7. **仅按需** Read 步骤 5 命中的 reference 文件，未命中的 mock 类别不要读。

## Step 1.5 — 计划确认（检查点）
向用户输出待办清单后等待确认。清单**必须显式引用 Step 0.5 的 4 项需求**：
- 待生成/修改的文件路径与新增/追加用例数（对照 `target_packages`）。
- **不可测文件清单**（来自 Step 1.4 的打标结果），注明各文件的 `[SKIP]` 原因。
- **加权可达上限**（扣除不可测语句后计算），若 `coverage_goal` 超过上限，明确提示"当前目标不可达，建议调整为 XX%"，让用户决定是继续还是降目标。
- 预计达成覆盖率（**必须基于语句数加权计算**，不得凭感觉估算）。
- 用例分布是否符合 `priority`（happy/error/edge 各几条）。
- TestMain 处置（按 `testmain_policy` 决定，见 Step 2）。
- 已检测的 FRPC 版本与 mock 类别命中列表。
- 项目测试规范声明（来自 Step 0.5 规范探测，如"将使用 table-driven 风格"）。
- 断言库探测：`grep -q 'github.com/stretchr/testify' go.sum && echo testify || echo stdlib`。命中 testify → 用 `assert`+`require`；否则用标准 `testing`。

未获确认前禁止写盘。

## Step 2 — TestMain 策略（4 分支决策）
| 现状 | 处置 |
|---|---|
| 已有 TestMain，且配置含 `application.Run` | **不动**，仅在汇报中列出已配置选项 |
| 已有 TestMain 但缺关键选项（如 `LoadTestLogConfig`/`InitTracerGoTest`） | **不擅改**，列出缺项让用户决定 |
| 没有 TestMain 且 Step 1 命中任一 mock 类别或需 trace/log | 在计划确认中**询问是否一并生成**，模板见下 |
| 没有 TestMain 且无外部依赖（纯函数） | **跳过**，直接写函数级用例 |

### TestMain 推荐模板（仅在用户同意后写入）
```go
func TestMain(m *testing.M) {
    application.Run(
        m.Run,
        application.WithConfigFile("conf/conf.toml"),
        application.OnLoadConfig(
            application.LoadTestLogConfig(),
            application.DeleteServerConfig(),
            application.DoNotCheckPortConsistency(),
        ),
        application.OnInit(
            application.InitTracerGoTest(0.001),
        ),
    )
}
```
若包不需启动 RPC Server，必须保留 `DeleteServerConfig` + `DoNotCheckPortConsistency`，否则端口冲突会失败。

## Step 3 — 用例生成规范

### 生产代码零改动
- **绝不修改非 `_test.go` 文件**。若某函数因未导出或无法注入依赖而难以测试，只能在计划中注明"需重构才可测，请用户决定"，不得擅自修改产品代码。

### 测试风格（项目规范优先）
- **表格驱动（项目有要求时强制）**：`[]struct{ name string; input ...; want ...; wantErr bool }` + `t.Run(tc.name, func(t *testing.T){ ... })`。每条 case 独立断言，禁止循环内共用变量。
- 项目无明确要求时，函数少于 3 个分支可用独立 `func Test*`，3 个及以上必须用 table-driven。
- **覆盖度**：每个目标函数至少 1 happy / 1 error / 1 edge。

### 全局状态隔离
- 凡测试修改包级变量（`atomic.Pointer`、全局单例、包级 `var`），**必须**用 `t.Cleanup` 恢复：
  ```go
  orig := globalVar.Load()
  t.Cleanup(func() { globalVar.Store(orig) })
  ```
- 禁止依赖测试执行顺序来保证全局状态正确。

### 追加安全（Edit 工具）
- 向既有 `_test.go` 末尾追加时，`old_string` **必须包含最后一个函数的完整结尾** `\n}`，避免原文件的闭括号残留导致双重 `}` 语法错误。
- 写入后立即 `go build ./...` 验证语法，通过再执行 Step 4。

### 其他规范
- **Mock 注册**：每条用例必要时在 `t.Run` 内 `mock.RegisterForTest(...)`，并 `defer` 清理；包级共享则放 TestMain。
- **Context**：需要 metadata/trace 的用例从 `metadata.WithIncomingContextForTest` 与 `trace.InitSpanContextForTest` 起手，参考 `references/metadata-and-trace.md`。
- **绝不静默覆盖**：发现既有 `_test.go` 同名函数测试，必须在 Step 1.5 显式请示"新增 / 追加用例 / 替换"。
- **Import 最小化**：只 import 实际使用的包，生成后检查 `go build` 是否报 `imported and not used`。

## Step 4 — 验证与失败兜底
- 写入后必须执行 `go test -v ./<目标包路径>`。
- 失败 → 读报错，针对性修复（mock 注册键不匹配、断言类型不符、TestMain 端口冲突等），最多 3 轮。
- 3 轮仍失败：保留已生成文件，向用户输出 {失败用例名、最后一次报错、推断根因、建议人工介入点}。

## Step 5 — 覆盖率对比摘要（必须输出）
测试通过后立即跑：`go test -cover -coverprofile=/tmp/frpc-cover-after.out ./<目标包>`，与 Step 1 的 `frpc-cover-before.out` 比对，输出 markdown 表格：

```markdown
### 覆盖率对比 — <目标包>
| 指标 | Before | After | Δ | 目标 |
|---|---|---|---|---|
| 总覆盖率 | XX.X% | YY.Y% | +N.N pp | `coverage_goal` |
| 已覆盖函数数 | a | b | +c | — |
| <100% 函数数 | x | y | -z | — |

**新增覆盖**（达到 100%）：fnA, fnB, ...
**仍未达标**（<100%）：fnC (剩余分支：...), ...
**目标达成**：✅/❌（达成 → 收工；未达成 → 列出建议增加的 case 类别）
```

覆盖率数据来源固定为 `go tool cover -func=<file> | tail -1`（总）+ `awk '$3 == "100.0%"' | wc -l`（已覆盖函数数）。

## 交付物
1. 生成/修改的文件路径列表（含 TestMain 是否新增）。
2. 命中的 mock 类别与对应 reference。
3. 覆盖场景摘要（happy/error/edge 拆分）。
4. `go test -v` 输出片段证明（如 `ok package/path 0.012s`）。
5. **Step 5 覆盖率对比表**（before/after/Δ/目标达成）。
