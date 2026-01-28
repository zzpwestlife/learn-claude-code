# 开发者指南

## 快速开始

### 前置要求
- Go 1.23+
- MySQL 5.7+
- 富途内网环境访问权限

### 本地开发
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

## 目录结构
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

## 调试

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
# 检查列类型匹配，查看 validateReqColumns 日志
tail -f app.log | grep "validate"
```

**问题**：FOSS 上传失败
```bash
# 检查 FOSS 配置
tail -f app.log | grep "foss"
```
