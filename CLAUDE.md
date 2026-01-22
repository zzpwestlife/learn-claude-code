# Project

Data Platform New Service (`data_platform_new_service`) 是一个基于 Go 的数据导出服务，负责处理合规数据平台的数据导出请求。服务支持多实体部署（Futunn, MooMoo, US/HK/SG/JP/AU/MY/CA Securities），提供数据查询、清洗、导出（CSV/Excel/PDF）及 FOSS 文件上传的完整 ETL 流水线。

**核心功能**：
- **记录处理 (Record)**: 数据导出任务的核心处理单元，支持 Query → Clean → Export 三阶段流水线
- **订阅处理 (Subscription)**: 定期订阅数据并生成导出文件
- **SPAC 数据处理**: 处理 SPAC（特殊目的收购公司）相关数据
- **任务取消**: 支持取消正在处理或待处理的任务
- **FOSS 集成**: 文件上传至富途对象存储服务

> ⚠️ **重要提示**：本项目遵循 [`constitution.md`](constitution.md) 定义的**开发宪法**，所有代码修改必须严格遵守其中的四条核心原则。

# Quick Start

## 前置要求

- Go 1.23+
- MySQL 5.7+
- 富途内网环境访问权限

## 本地开发

```bash
# 1. 克隆项目（包含子模块）
git clone --recurse-submodules <repo_url>
cd data_platform_new_service

# 2. 安装依赖
make dep

# 3. 复制配置文件
cp conf/conf.toml.sample conf/conf.toml

# 4. 修改配置文件中的数据库连接等配置
vim conf/conf.toml

# 5. 运行服务
make run
```

## 配置说明

配置文件位于 `conf/conf.toml`，主要配置项：

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| `[frpc.server.srpc].port` | gRPC 服务端口 | 17890 |
| `[frpc.server.http].port` | HTTP 服务端口 | 17891 |
| `[frpc.mysql.data_platform_new]` | MySQL 数据库连接 | - |
| `[frpc.log].level` | 日志级别 | debug |
| `[foss]` | FOSS 对象存储配置 | - |
| `[uni_api_config]` | UniApiGateway 配置 | - |

# Stack

- **Language**: Go 1.23
- **Framework**: frpc (Futu RPC framework)
- **Database**: MySQL (通过 GORM)
- **Protocol**: gRPC/Protobuf
- **Storage**: FOSS (Futu Object Storage Service)
- **Testing**: testify, goconvey
- **Cron**: robfig/cron/v3
- **PDF**: gopdf
- **Excel**: excelize/v2

# Structure

```
internal/app/
├── biz/                    # 业务逻辑层
│   ├── record/            # 记录处理核心模块
│   ├── subscription/      # 订阅业务逻辑
│   ├── codemapping/       # 代码映射
│   ├── check/             # 数据校验
│   ├── email/             # 邮件发送
│   ├── logic/
│   │   ├── convert/       # 数据转换（DB/CSV）
│   │   ├── export/        # 导出功能 (CSV/Excel/PDF)
│   │   └── clean/         # 数据清洗
│   ├── config/            # 配置管理
│   ├── utils/             # 工具类（meta/file/date 等）
│   ├── constant/          # 常量定义
│   └── web/               # Web 处理器
├── service/               # gRPC service 实现
├── worker/cron/           # 定时任务 Worker
│   ├── record.go         # 记录处理任务
│   ├── subscription.go   # 订阅处理任务
│   ├── spac.go           # SPAC 数据处理
│   ├── cancel.go         # 任务取消
│   ├── foss.go           # FOSS 文件下载
│   └── summary.go        # 汇总任务
├── model/                 # 数据模型
│   ├── data_platform_new_db/  # GORM 生成的 DB 模型
│   └── interaction/      # 交互模型
├── api/rpc/              # RPC 客户端
│   ├── customer_profile/ # 客户资料服务
│   ├── uni_api_gateway/  # 统一 API 网关
│   └── foss/             # FOSS 服务
└── mocks/                # Mock 数据
```

**请求流程**：
```
gRPC Request → service (API) → biz (业务逻辑) → logic/convert/clean/export → repo (数据库) → GORM → Database
                                                                  ↓
                                                            FOSS 上传文件
```

# Rules

## 指令规范 (Anti-Hallucination & Safety)

- **Ambiguity Handling**: 若用户指令存在歧义（如"跟上面一样"），必须先明确具体方案再执行，严禁猜测。
- **Batch Operations**: 对于涉及大量文件（>5 个）的修改，**必须**先在一个文件中验证方案（Prototype），确认无误后再批量执行。
- **Precision**: 在理解需求时，优先匹配具体的文件名、变量名和代码符号。

## 代码规范

- **格式化**：使用 `gofumpt`，运行 `make fmt` 或 `gofumpt -l -w .`
- **包命名**：简洁、小写（如 `record` 而非 `record_service`）
- **错误处理**：
  - 所有错误必须显式处理，绝不使用 `_` 丢弃
  - 错误传递必须包装上下文：`fmt.Errorf("operation failed: %w", err)`
  - 避免嵌套过深的错误处理，早返回（early return）

## 测试规范

- **测试覆盖率**：关键业务逻辑（如记录处理流水线）必须有完整测试
- **测试模式**：使用 goconvey 和 table-driven tests
- **Mock 工具**：使用函数变量替换或接口注入进行 mock

## Makefile 目标

| 目标 | 说明 |
|------|------|
| `make help` | 显示所有可用目标 |
| `make dep` | 安装依赖 (`go mod tidy`) |
| `make fmt` | 格式化代码 (`go fmt`) |
| `make lint` | 运行 golangci-lint 检查 |
| `make vet` | 运行 `go vet` 静态分析 |
| `make test` | 运行单元测试，生成覆盖率报告 |
| `make race` | 运行竞态检测 |
| `make build` | 构建可执行文件到 `bin/` |
| `make build-dev` | 构建开发版本（禁用优化） |
| `make run` | 直接运行服务 (`go run cmd/main.go`) |
| `make start` | 后台启动服务 |
| `make stop` | 停止后台服务 |
| `make stub_test` | 运行 stub 测试 |
| `make all` | 执行 fmt + lint + vet + test + race + build |

### 测试运行

```bash
# 运行所有单元测试
make test

# 查看测试覆盖率报告
open unittest_cov/cover.html

# 运行特定包的测试
go test -v ./internal/app/biz/record/...

# 运行集成测试
go test -v ./internal/app/biz/record/... -tags=integration

# 运行竞态检测
make race
```

## 数据库访问规范

```go
// ✅ 推荐：使用上下文和错误处理
func (r *RecordRepo) UpdateRecordIfMatchStatus(ctx context.Context, record *data_platform_new_db.Record, status string) error {
    result := q.Record.WithContext(ctx).
        Where(q.Record.ID.Eq(record.ID)).
        Where(q.Record.Status.Eq(record.Status)).
        Updates(map[string]interface{}{"status": status})
    if result.RowsAffected == 0 {
        return constant.UpdateRecordStatusEffectRowsZeroErr
    }
    return result.Error
}

// ❌ 避免：无上下文，忽略错误
func (r *RecordRepo) UpdateBad(record *data_platform_new_db.Record) {
    q.Record.Updates(record) // 忽略错误和上下文！
}
```

## Context 使用规范

```go
// ✅ 正确：传递 context，支持超时和取消
func HandleRecord(ctx context.Context, record *data_platform_new_db.Record) error {
    // 处理逻辑...
}

// ✅ Worker 中使用超时上下文
tCtx, cancel := context.WithTimeout(tCtx, 1*time.Hour)
defer cancel()
```

## 日志规范

```go
// ✅ 结构化日志，带上下文
log.Info(ctx, "handle_record_success",
    log.Uint64("recordID", record.ID),
    log.String("filePath", resFilePath),
)

// ✅ 错误日志带监控
log.Error(ctx, "update_status_to_inprocess_error",
    log.ErrorField(err),
)
metric.EventsTotal.WithLabels(...).Inc()
```

## 并发模式

```go
// ✅ 使用 errgroup 管理并发任务
import "golang.org/x/sync/errgroup"

func handleProcess(ctx context.Context, record *data_platform_new_db.Record) (string, error) {
    g, gCtx := errgroup.WithContext(ctx)

    // Query 阶段
    dataCh := make(chan *Data, 10)
    g.Go(func() error {
        return queryData(gCtx, record, dataCh)
    })

    // Clean 阶段
    cleanCh := make(chan *Data, 10)
    g.Go(func() error {
        return cleanData(gCtx, dataCh, cleanCh)
    })

    // Export 阶段
    g.Go(func() error {
        return exportData(gCtx, cleanCh, record)
    })

    return "", g.Wait()
}
```

## 核心概念

### ETL 三阶段流水线

记录处理采用经典的 Extract-Transform-Load 模式：

```
Query (查询) → Clean (清洗) → Export (导出)
     ↓              ↓              ↓
  外部API调用    数据转换验证    文件生成+上传FOSS
```

**Query 阶段** (`queryData`)：
- 调用 UniApiGateway 获取数据
- 支持 API 分页查询
- 使用 `select` 监听 `ctx.Done()` 实现优雅取消

**Clean 阶段** (`cleanData`)：
- 数据转换（列名映射、类型转换）
- 日期格式统一
- 数据校验和清洗

**Export 阶段** (`exportData`)：
- 支持 CSV、Excel、PDF 三种格式
- 文件上传至 FOSS
- 返回文件路径

### 分布式任务锁

通过 `UpdateRecordIfMatchStatus` 实现乐观锁：

```go
// 状态转换：Init → InProcess
ok := repo.UpdateRecordIfMatchStatus(ctx, record, pb.RecordStatus_InProcess.String())
if ok == constant.UpdateRecordStatusEffectRowsZeroErr {
    return nil // 已被其他实例处理
}
```

**工作原理**：
1. 使用 WHERE 条件同时匹配 ID 和当前状态
2. 只有状态匹配时才能更新成功
3. 防止多实例重复处理同一任务

### 记录状态机

```
                    ┌─────────────────┐
                    │     Init        │ 初始状态
                    └────────┬────────┘
                             │ HandleRecord
                             ↓
                    ┌─────────────────┐
                    │   InProcess     │ 处理中
                    └────────┬────────┘
                             │
            ┌────────────────┼────────────────┐
            ↓                ↓                ↓
      ┌──────────┐    ┌──────────┐    ┌──────────┐
      │  Success │    │   Init   │    │  Failed  │
      └──────────┘    └──────────┘    └──────────┘
       (成功)        (重试)          (失败，达最大次数)
```

**状态值**（`pb.RecordStatus_*`）：
- `Init` = 初始状态，待处理
- `InProcess` = 处理中
- `Success` = 处理成功
- `Failed` = 处理失败（达到最大重试次数）
- `Canceled` = 已取消

### 任务取消机制

双阶段取消策略（`worker/cron/cancel.go`）：

```go
// 阶段 1: 尝试取消 Init 状态的任务
ok := repo.UpdateRecordIfMatchStatus(ctx, rec, constant.RecordStatusCanceled)

// 阶段 2: 如果失败（可能已进入 InProcess），尝试取消 InProcess 状态的任务
if err == constant.UpdateRecordStatusEffectRowsZeroErr {
    rec.Status = pb.RecordStatus_InProcess.String()
    return repo.UpdateRecordIfMatchStatus(ctx, rec, constant.RecordStatusCanceled)
}
```

### 实体常量

支持的多实体（`constant.Entity*`）：
- `EntityFutunn` - 富途牛牛
- `EntityMooMoo` - 芝麻企业
- `EntityUsSec` / `EntityHkSec` / `EntitySgSec` / `EntityJpSec` / `EntityAuSec` / `EntityMySec` / `EntityCaSec` - 各地证券
- `EntityUsClearing` - 美国清算

## 常量约定

- 记录状态：`pb.RecordStatus_Init`, `pb.RecordStatus_InProcess`, `pb.RecordStatus_Success`, `pb.RecordStatus_Failed`
- 最大重试次数：`constant.RecordMaxTryTimes` = 3
- 批量大小：`constant.SetUpOrderBatchSize` = 50
- 查询限制：`constant.QueryInSizeLimit` = 10000
- 文件后缀：`constant.CsvFileSuffix` = ".csv", `constant.PdfFileSuffix` = ".pdf"

## 外部依赖

### UniApiGateway（统一 API 网关）
- 数据查询接口
- 路径：`gitlab.futunn.com/artifact-go/api-gateway`

### FOSS（富途对象存储服务）
- 文件上传/下载
- 路径：`gitlab.futunn.com/golibs/golibs/gofoss`

### Customer Profile（客户资料服务）
- 客户信息查询
- 路径：`gitlab.futunn.com/artifact-go/common/customer_common`

## Code Review Checklist

提交代码前自查：
- [ ] 所有错误已显式处理，无 `_` 丢弃
- [ ] 已运行 `make fmt` 无错误
- [ ] 数据库操作使用上下文
- [ ] 日志使用结构化格式，包含关键字段
- [ ] 无 `panic()`，使用 `return err` 传递错误
- [ ] Context 传播正确，支持取消
- [ ] 分布式锁使用正确（状态机转换）
- [ ] 测试覆盖核心业务逻辑

## 调试技巧

### 常用调试命令

```bash
# 手动触发记录处理任务
curl "http://127.0.0.1:17891/frpc/cron/HandleRecord" -G

# 手动取消任务
curl "http://127.0.0.1:17891/frpc/cron/CancelTask" -d 'taskId=267' -G

# FOSS 文件下载测试
curl "http://127.0.0.1:17891/frpc/cron/fossDownload" \
  -d 'FOSSFilePath=/path/to/file.csv&downloadFilePath=/tmp/file.csv' -G

# 查看日志
tail -f /path/to/app.log | grep -E "handle_record|export"
```

### 常见问题排查

**问题**：任务未被处理
```bash
# 检查记录状态
mysql> SELECT id, status, try_times FROM record WHERE id = <record_id>;

# 查看处理日志
tail -f app.log | grep "recordID=<record_id>"
```

**问题**：导出文件格式错误
```bash
# 检查列类型匹配
# 查看 validateReqColumns 日志
tail -f app.log | grep "validate"
```

**问题**：FOSS 上传失败
```bash
# 检查 FOSS 配置
tail -f app.log | grep "foss"
```

## 环境变量

虽然配置主要通过 `conf/conf.toml` 管理，但某些场景下可能需要设置环境变量：

| 变量 | 说明 |
|------|------|
| `GOPROXY` | Go 模块代理 |
| `GONOPROXY` | 跳过代理的域名 |
| `HOST_NETWORK_ENVIRONMENT` | 网络环境 (DEV/TEST/PROD) |
| `CMLB_PROXY_URL` | CMLB 代理地址 |
| `MONITOR_PROXY_URL` | 监控代理地址 |
| `FTRACE_UDP_AGENT_HOST` | FTRACE UDP Agent 地址 |
| `CONSUL_AGENT_ADDRESS` | Consul Agent 地址 |

```bash
# 设置内网 Go 代理（富途环境）
export GOPROXY="https://mirrors.tencent.com/go/,direct"
export GONOPROXY=*.futunn.com,*.oa.com
```

# Output

回复语言：中文（说明），英文（技术术语）
风格：简洁、专业、工程化
引用：提及代码路径时使用相对路径（如 `internal/app/biz/record/`）
