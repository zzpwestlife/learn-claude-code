---
name: kafka-frpc
description: frpc 项目 Kafka 接入向导：conf.toml 配置（多地区速查）、生产者/消费者代码、接入 Checklist。触发词：接入 kafka / 新增 kafka 消费者 / kafka 生产者 / add kafka consumer / kafka producer / kafka frpc 配置。
---

# Kafka × frpc 接入向导

引导用户在任意 frpc Go 项目中完成 Kafka 接入。覆盖：conf.toml 配置、生产者、消费者、接入 Checklist。

---

## 0. 接入工作流

> **快速跳转**：只要配置 → §1 | 只要代码 → §3/§4 | 报错排查 → §6 FAQ | 接入完成验收 → §5

按以下步骤顺序引导用户：

**Step 0 — 现状探查**（先做，再问需求）
→ 在项目代码库中搜索已有 Kafka 配置：`grep -r "frpc.kafka" --include="*.toml" .`
→ 查看已有 `[frpc.kafka.xxx]` 段，了解现有 config_key 命名风格，避免重复或冲突。
→ 若已有配置，展示给用户确认是复用还是新增。

**Step 1 — 需求采集**（用 AskUserQuestion 逐项收集，等用户回答后再继续）

第一问：接入地区（multiSelect: true，列出所有选项）
```
options: AU, CA, HK, HKVA, JP, MY, SG, TH, US, USVA
```

第二问：用途（单选）
```
options: 只需生产者, 只需消费者, 生产者+消费者都要
```

第三问：使用环境（单选，**影响 address 格式**）
```
options: 本地/测试（IP:port）, 线上（fns://）
```

第四问（文本）：topic 名是什么？

第五问（文本，**仅当用途包含消费者时才问**）：consumer group id 是什么？

**Step 2 — 给配置**
→ 查 Section 1 速查表，给出对应的 conf.toml 配置块（按用途只给需要的段）。
→ address 格式按使用环境决定：
  - **线上**：`address = "fns://kafka_finrd_mq"`
  - **本地/测试**：`address = "<IP>:<port>"`（请用户提供 broker 地址）
→ 提醒：新配置块追加到 **`conf/conf.toml` 文件末尾**，除非用户指定了其他配置文件。若找不到 `conf/conf.toml`，询问用户配置文件路径。
→ 提醒：账号密码向 joeyzou 获取，告知地区 + topic + 读/写权限。

**Step 2.5 — 配置确认**（检查点）
→ 给完配置后问：「配置看起来正确吗？config_key / topic / group id 是否需要调整？」
→ 等用户确认后再继续，有改动则更新配置块。

**Step 3 — 给代码**
→ 按需给出 Section 3（生产者）/ Section 4（消费者）代码，替换占位符。

**Step 4 — Checklist 确认**
→ 展示 Section 5 Checklist，逐项引导用户确认。完成后结束。

---

## 0.5 本 Skill 的边界

**适用**：在已有 frpc Go 项目中接入 Kafka（配置、生产者、消费者）。

**不适用**：
- 非 frpc 框架（原生 sarama、confluent-kafka 等）→ 直接给原生用法
- 搭建 Kafka 集群 / 运维集群 → 超出本 Skill 范围
- 生产环境鉴权配置 → 本 Skill 仅覆盖测试环境；生产环境联系 joeyzou
- 地区不在速查表且无法确认集群类型 → 使用 Section 2 通用模板，并提示用户确认鉴权方式

**FAQ 未覆盖的连接失败 — 通用兜底路径**：
1. 先检查 Section 2 鉴权规则表（TLS / SASL mechanism 是否匹配集群类型）
2. 本地测试连通性：`nc -zv <broker-ip> 9092`（或 `telnet <broker-ip> 9092`）
3. 仍失败 → 提供给 joeyzou：错误日志全文 + 地区 + 集群类型（AWS/CKafka/AliKafka）

---

## 1. 地区配置速查

> 测试环境配置。**密码请联系 joeyzou 获取**（告知：地区、topic 名、读/写权限）。

### 参数速查表

| 地区 | 云厂商 | mechanism | TLS | SASL user |
|------|--------|-----------|:---:|-----------|
| AU | AWS MSK | SCRAM-SHA-512 | ✅ | `bda` |
| CA | AWS MSK | SCRAM-SHA-512 | ✅ | `bda` |
| HK | 腾讯云 CKafka | SCRAM-SHA-256 | ❌ | `ckafka-jmqqwo7b#test_user` |
| HKVA | 腾讯云 CKafka | SCRAM-SHA-256 | ❌ | `ckafka-542257a8#test_user` |
| JP | 腾讯云 CKafka | SCRAM-SHA-256 | ❌ | `ckafka-pbpw5go7#test_user` |
| MY | 阿里云 AliKafka | PLAINTEXT | ❌ | （无需鉴权） |
| SG | 腾讯云 CKafka | SCRAM-SHA-256 | ❌ | `ckafka-b4bqdbrn#test_user` |
| TH | 腾讯云 CKafka | SCRAM-SHA-256 | ❌ | `ckafka-dm3j2bka#test_user` |
| US/USVA | 腾讯云 CKafka | SCRAM-SHA-256 | ❌ | `ckafka-rkazwkwr#test_user` |

> **关键坑**：AWS MSK 必须开 TLS；CKafka 开 TLS 反而报错。两者完全相反。

### conf.toml 配置模板

**SASL 鉴权（AU/CA/HK/HKVA/JP/SG/TH/US/USVA）** — 查表填入 mechanism 和 user：

```toml
[frpc.kafka.<config_key>]
address            = "fns://kafka_finrd_mq"   # 线上；本地/测试改为 "<IP>:<port>"
net.tls.enable     = true               # 仅 AU/CA（AWS MSK）需要，其他地区删掉此行
net.sasl.enable    = true
net.sasl.mechanism = "<从表中取>"        # AU/CA=SCRAM-SHA-512；其余=SCRAM-SHA-256
net.sasl.user      = "<从表中取>"
net.sasl.password  = "***"             # 向 joeyzou 获取
client_id          = "<your_service_name>"
rack_id            = "#INNER_IP"

[frpc.kafka.<config_key>.producer]
required_acks = "WaitForAll"

[frpc.kafka.<config_key>.consumers.<consumer_key>]
topics              = ["<TopicName>"]
disable_start_check = true
[frpc.kafka.<config_key>.consumers.<consumer_key>.group]
id = "<consumer-group-id>"
```

**MY（阿里云 PLAINTEXT · 无鉴权）**：

```toml
[frpc.kafka.<config_key>]
address         = "fns://kafka_finrd_mq"   # 线上；本地/测试改为 "<IP>:<port>"
net.sasl.enable = false
client_id       = "<your_service_name>"
rack_id         = "#INNER_IP"

[frpc.kafka.<config_key>.producer]
required_acks = "WaitForAll"

[frpc.kafka.<config_key>.consumers.<consumer_key>]
topics              = ["<TopicName>"]
disable_start_check = true
[frpc.kafka.<config_key>.consumers.<consumer_key>.group]
id = "<consumer-group-id>"
```

### 完整示例（SG · 消费者 · topic=OrderEvents）

```toml
[frpc.kafka.order_kafka]
address            = "fns://kafka_finrd_mq"
net.sasl.enable    = true
net.sasl.mechanism = "SCRAM-SHA-256"
net.sasl.user      = "ckafka-b4bqdbrn#test_user"
net.sasl.password  = "***"
client_id          = "order-svc"
rack_id            = "#INNER_IP"

[frpc.kafka.order_kafka.consumers.order_consumer]
topics              = ["OrderEvents"]
disable_start_check = true
[frpc.kafka.order_kafka.consumers.order_consumer.group]
id = "order-svc-group"
```

---

## 2. 其他地区/自建集群通用模板

仅在地区不在上方速查表时使用。参照以下鉴权规则填写：

| 集群类型 | TLS | SASL | mechanism |
|---------|-----|------|-----------|
| **AWS MSK** | ✅ 必须开启 | ✅ | SCRAM-SHA-512 |
| **腾讯云 CKafka** | ❌ 不能开启 | ✅ | SCRAM-SHA-256 |
| **阿里云 AliKafka** | ❌ | ❌ | PLAINTEXT |
| **自建/其他** | 按实际 | 按实际 | PLAIN 或 SCRAM-SHA-256 |

> **关键坑**：AWS MSK 必须开 TLS；CKafka 开 TLS 反而报错。两者相反。

```toml
[frpc.kafka.<config_key>]
address            = "fns://<fns_service_name>"
# address          = "10.x.x.1:9092"   # 本地测试换直连
net.tls.enable     = true               # AWS MSK 必须；CKafka 删掉此行
net.sasl.enable    = true
net.sasl.mechanism = "SCRAM-SHA-512"    # CKafka 改为 SCRAM-SHA-256
net.sasl.user      = "<username>"
net.sasl.password  = "<password>"
client_id          = "<your_service_name>"
rack_id            = "#INNER_IP"

[frpc.kafka.<config_key>.producer]
required_acks = "WaitForAll"

[frpc.kafka.<config_key>.consumers.<consumer_key>]
topics              = ["<TopicName>"]
disable_start_check = false
[frpc.kafka.<config_key>.consumers.<consumer_key>.group]
id = "<consumer-group-id>"
```

---

## 3. 生产者代码

```go
import (
    "context"
    "time"

    "gitlab.futunn.com/infra/frpc/pkg/thirdparty/mq/kafka"
)

const (
    kafkaConfigKey = "<config_key>"
    topicName      = "<TopicName>"
)

// 同步发送（推荐，发送失败立即拿到错误）
func produce(ctx context.Context, partitionKey string, payload []byte) error {
    producer, err := kafka.GetSyncProducer(kafkaConfigKey)
    if err != nil {
        return err
    }
    _, _, err = producer.SendMessageContext(ctx, &kafka.ProducerMessage{
        Topic:     topicName,
        Key:       kafka.StringEncoder(partitionKey),
        Value:     kafka.ByteEncoder(payload),
        Timestamp: time.Now(),
    })
    return err
}
```

> **不要缓存 producer**：`GetSyncProducer` 每次返回框架托管的实例，直接调用即可。

---

## 4. 消费者代码

消费者在 `init()` 中注册，frpc 框架自动启动。

```go
import (
    "context"

    "github.com/Shopify/sarama"
    "gitlab.futunn.com/infra/frpc/pkg/thirdparty/mq/kafka"
)

const (
    kafkaConfigKey = "<config_key>"
    consumerKey    = "<consumer_key>"
)

func init() {
    _ = kafka.RegisterConsumer(kafkaConfigKey, consumerKey, handleMsg)
}

func handleMsg(
    ctx context.Context,
    session sarama.ConsumerGroupSession,
    msg *kafka.ConsumerMessage,
) error {
    defer session.MarkMessage(msg, "")  // 用 defer 确保任何情况下都会 mark

    if err := processMessage(ctx, msg.Value); err != nil {
        // handler 返回 error 不会自动重试 — 在此消化并记录
        log.Errorf("kafka msg error: topic=%s offset=%d err=%v", msg.Topic, msg.Offset, err)
    }
    return nil
}
```

> **at-least-once**：rebalance/重启等场景同一消息可能被投递多次，`processMessage` 需幂等（如以 msg.Key 或唯一业务 ID 去重）。

---

## 5. 接入 Checklist

引导用户逐项确认：

```
□ conf.toml 已添加 [frpc.kafka.<config_key>] 连接配置
□ 鉴权模式与集群类型匹配（AWS=TLS+512 / CKafka=无TLS+256 / Ali=PLAINTEXT）
□ 需要生产：已添加 [frpc.kafka.<config_key>.producer] 配置
□ 需要消费：已添加 [frpc.kafka.<config_key>.consumers.<consumer_key>] 配置
□ 生产者：调用 kafka.GetSyncProducer + SendMessageContext
□ 消费者：在 init() 调用 kafka.RegisterConsumer
□ 消费者 handler 中已调用 session.MarkMessage(msg, "")
□ address 格式已按环境正确设置（线上=fns://kafka_finrd_mq，本地/测试=直连 IP:port）
```

---

## 6. 常见问题

| 现象 | 原因 | 解决 |
|------|------|------|
| `SASL Error 34 / IllegalSASLState` | AWS MSK 端口需要先 TLS 握手，再 SASL | 开启 `net.tls.enable = true` |
| CKafka TLS 握手失败 | 腾讯云 CKafka 不支持 TLS | 确认 `net.tls.enable` 未设置或注释掉 |
| `Topic Authorization Failed (Error 29)` | 账密错误或 ACL 未授权 | 检查 user/password，联系集群管理员确认 ACL |
| 消费者重复消费 | handler 内未调用 `session.MarkMessage` | 补上 `session.MarkMessage(msg, "")` |
| 本地无法连接 `fns://` 地址 | FNS 服务发现依赖内网，本地无法解析 | 将 address 改为直连 IP:port |

---

## 参考

> 本 Skill 已内嵌所有常规接入所需参考资料（§1 配置、§3/§4 代码、§5 Checklist、§6 FAQ）。以下为进阶资源。

| 资源 | 路径 | 说明 |
|------|------|------|
| 完整集成指南 | `reference/kafka-frpc-integration-guide.md` | 覆盖 Setup/Cleanup 钩子、分区处理器等高级消费者模式（§4.2、§4.3） |
| Verifyall 工具 | `reference/verifyall-tutorial.md` | 验证跨地区 Kafka 连通性的 verifyall 工具用法 |
