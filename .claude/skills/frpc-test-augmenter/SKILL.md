---
name: "frpc-test-augmenter"
description: "Augment unit tests for existing FRPC Go codebases (gitlab.futunn.com/infra/frpc) to raise coverage. Trigger when user asks 补单测/补充测试用例/提升覆盖率/加测试 for an FRPC repo. SKIP if go.mod lacks frpc dependency."
version: "1.0.0"
tags: ["FRPC", "Golang", "Testing", "Coverage", "Mock"]
categories: ["开发工具", "测试"]
---

# FRPC Test Augmenter

## 简介
针对**已有 FRPC 代码库**（`gitlab.futunn.com/infra/frpc`，v1.14.2+）的测试用例补充器，目标是**提升覆盖率**。基于既有测试基线做增量：识别未覆盖的函数与分支，复用框架测试基建（`application.Run`、RPC/HTTP/Redis/Kafka/RabbitMQ Mock、Metadata、log/trace），**外科手术式**追加用例，不破坏既有结构。

## TL;DR — 流程速查
| Step | 输入 | 关键产物 |
|---|---|---|
| 0 前置检测 | `go.mod` | frpc 版本、过/不过 |
| 1 覆盖率盘点 | 目标包 | 未覆盖函数清单 + 命中的 mock 类别 |
| 1.5 计划确认 | 函数清单 | 用户签字的待办清单 |
| 2 TestMain 决策 | 同包 *_test.go | 不动 / 询问新增 / 跳过 |
| 3 用例生成 | 决策 + reference | 表驱动用例 + mock 注册 |
| 4 验证 | 新文件 | `go test -v` 通过 |

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

## Step 1 — 覆盖率盘点 + 上下文分析
1. **覆盖率基线**：执行 `go test -cover -coverprofile=/tmp/frpc-cover.out ./<目标包>` 获取既有覆盖率与未覆盖行；失败（如包内无测试）则视为 0%，记录 `no_baseline=true`。
2. 解析 `coverprofile`：列出**未覆盖的函数**与**部分覆盖的分支**。一行命令取 <100% 函数清单：`go tool cover -func=/tmp/frpc-cover.out | awk '$3 != "100.0%"'`（最后一行 total 忽略）。
3. Read 目标文件，对未覆盖函数列出入参/返回值与可能错误分支。
4. 静态扫描函数体内的 import 与调用，识别**外部依赖类别**（仅出现以下类别才需对应 mock）：

| 信号 | 依赖类别 | 待加载 reference |
|---|---|---|
| 调用 `*Client.XXX(ctx, req)` 形如 RPC | RPC | `references/rpc-mock.md` |
| `gitlab.futunn.com/infra/frpc/pkg/http` 或硬编码外部 URL | HTTP | `references/http-mock.md` |
| `redis.UniversalClient` / `distributedlock` | Redis | `references/redis-mock.md` |
| `sarama.ConsumerGroupSession` / `kafka.ConsumerMessage` | Kafka | `references/kafka-mock.md` |
| `amqp.Delivery` / `Acknowledger` | RabbitMQ | `references/rmq-mock.md` |
| `metadata.FromIncomingContext` / `srpc.CRpcHead` / 链路追踪 | Metadata/Trace | `references/metadata-and-trace.md` |

5. 同包扫描：`ls` 同目录 `*_test.go`，记录已存在的 TestMain 与已覆盖函数（与覆盖率清单交叉验证）。
6. **仅按需** Read 步骤 4 命中的 reference 文件，未命中的 mock 类别不要读。

## Step 1.5 — 计划确认（检查点）
向用户输出待办清单后等待确认：
- 待生成/修改的文件路径与新增/追加用例数。
- 已检测的 FRPC 版本与 mock 类别命中列表。
- TestMain 处置策略（见 Step 2）。
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
- **表格驱动**：`[]struct{ name string; args args; want want; wantErr bool }` + `t.Run`。
- **覆盖度**：每个目标函数至少 1 happy / 1 error / 1 edge。
- **Mock 注册**：每条用例必要时在 `t.Run` 内 `mock.RegisterForTest(...)`，并 `defer` 清理；包级共享则放 TestMain。
- **Context**：需要 metadata/trace 的用例从 `metadata.WithIncomingContextForTest` 与 `trace.InitSpanContextForTest` 起手，参考 `references/metadata-and-trace.md`。
- **绝不静默覆盖**：发现既有 `_test.go` 同名函数测试，必须在 Step 1.5 显式请示"新增 / 追加用例 / 替换"。

## Step 4 — 验证与失败兜底
- 写入后必须执行 `go test -v ./<目标包路径>`。
- 失败 → 读报错，针对性修复（mock 注册键不匹配、断言类型不符、TestMain 端口冲突等），最多 3 轮。
- 3 轮仍失败：保留已生成文件，向用户输出 {失败用例名、最后一次报错、推断根因、建议人工介入点}。

## 交付物
1. 生成/修改的文件路径列表（含 TestMain 是否新增）。
2. 命中的 mock 类别与对应 reference。
3. 覆盖场景摘要（happy/error/edge 拆分）。
4. `go test -v` 输出片段证明（如 `ok package/path 0.012s`）。
