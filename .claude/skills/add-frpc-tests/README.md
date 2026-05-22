# add-frpc-tests (Skill)

针对 **FRPC Go 项目**（`gitlab.futunn.com/infra/frpc` v1.14.2+）的测试用例补充器，目标是提升覆盖率。识别未覆盖函数与分支，复用框架 Mock 基建，外科手术式追加测试，不破坏既有结构。

---

## 触发词

```
补单测 / 补充测试用例 / 提升覆盖率 / 加测试
```

示例：
- "帮我给 `internal/service/order` 这个包补单测，提升覆盖率"
- "这个 Kafka 消费者 handler 没有测试，帮我加几个 error 分支用例"

---

## 工作流程

| Step | 说明 |
|---|---|
| 0 前置检测 | 检查 `go.mod` 含 frpc 且版本 ≥ v1.14.2 |
| 0.5 需求采集 | 收集目标包、覆盖率目标、优先级、TestMain 策略 |
| 1 覆盖率盘点 | 列出未覆盖函数，标记不可测文件，计算加权可达上限 |
| 1.5 计划确认 | 展示待办清单，用户确认后才写盘 |
| 2 TestMain 决策 | 决定是否新增 / 保留 / 跳过 TestMain |
| 3 用例生成 | 表驱动或独立函数，mock 注册，全局状态隔离 |
| 4 验证 | `go test -v` 通过，最多 3 轮修复 |
| 5 覆盖率对比 | Before/After/Δ markdown 表 + 目标达成判定 |

---

## 支持的 Mock 类型

| 依赖类别 | 参考文件 |
|---|---|
| RPC Client | `references/rpc-mock.md` |
| HTTP Client | `references/http-mock.md` |
| Redis | `references/redis-mock.md` |
| Kafka 消费者 | `references/kafka-mock.md` |
| RabbitMQ | `references/rmq-mock.md` |
| Metadata / Trace | `references/metadata-and-trace.md` |

---

## 核心约束

- **零改动原则**：绝不修改非 `_test.go` 的生产代码。
- **表驱动优先**：项目有要求时强制使用 `[]struct{name;...}+t.Run`。
- **全局状态隔离**：修改包级变量时必须用 `t.Cleanup` 恢复。
- **预估必须加权**：扣除不可测文件后计算可达上限，不凭感觉承诺。

---

## 不适用场景

- `go.mod` 不含 frpc 依赖 → 改用通用 Go 测试 skill
- frpc 版本 < v1.14.2 → 提示升级或人工接入
- Python / 非 Go 项目
- cgo 代码、`// Code generated` 文件、`//go:build integration` 构建标签
