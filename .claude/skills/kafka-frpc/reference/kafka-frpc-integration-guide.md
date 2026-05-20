# Kafka × frpc 接入指南

> **目标**：任何 frpc Go 项目，按此文档可独立完成 Kafka 生产者与消费者接入，无需额外依赖。

---

## 1. 前提

- frpc 版本 ≥ v1.27.0
- 已有可用 Kafka 集群（支持 SASL/SCRAM 或无鉴权）
- 已在 FNS 注册服务名（内网服务发现）；直连地址同样支持

---

## 2. conf.toml 配置

### 2.1 公共连接配置

```toml
[frpc.kafka.<config_key>]
# 测试环境：直连 IP:port（多个 broker 用逗号分隔）
# address = "10.x.x.1:9092,10.x.x.2:9092"
# 生产环境：FNS 服务发现
address = "fns://<fns_service_name>"
net.dial_timeout  = "5s"
net.read_timeout  = "5s"
net.write_timeout = "5s"

# SASL 鉴权（无鉴权时删除此块）
net.sasl.enable    = true
net.sasl.mechanism = "SCRAM-SHA-256"   # 或 PLAIN
net.sasl.user      = "<username>"
net.sasl.password  = "<password>"

client_id = "<your_service_name>"  # Kafka 侧可见，建议填服务名
rack_id   = "#INNER_IP"            # frpc 宏，自动替换为实例 IP
```

**`<config_key>`** 是整段配置的标识符，生产者和消费者代码都通过它引用此配置。

### 2.2 生产者配置

```toml
[frpc.kafka.<config_key>.producer]
required_acks = "WaitForAll"  # NoResponse | WaitForLocal | WaitForAll
timeout       = "5s"
```

### 2.3 消费者配置

```toml
[frpc.kafka.<config_key>.consumers.<consumer_key>]
topics              = ["<TopicName>"]
group.id            = "<consumer-group-id>"
log_access_level    = "info"    # info | debug
disable_start_check = false     # true = 连接失败时仍启动，运行时再报错
```

- **`<consumer_key>`** 是消费者逻辑名，同一 `<config_key>` 下可有多个消费者。
- `group.id` 同一消费组内多实例负载均衡；不同消费组各自独立消费。

---

## 3. 生产者

### 3.1 发送消息（同步）

```go
import (
    "context"
    "time"

    "gitlab.futunn.com/infra/frpc/pkg/thirdparty/mq/kafka"
)

const (
    kafkaConfigKey = "<config_key>"  // 对应 conf.toml 中的 key
    topicName      = "<TopicName>"
)

func produce(ctx context.Context, partitionKey string, payload []byte) error {
    // frpc 管理连接池，无需手动创建/关闭
    producer, err := kafka.GetSyncProducer(kafkaConfigKey)
    if err != nil {
        return err
    }
    _, _, err = producer.SendMessageContext(ctx, &kafka.ProducerMessage{
        Topic:     topicName,
        Key:       kafka.StringEncoder(partitionKey), // 影响分区路由
        Value:     kafka.ByteEncoder(payload),
        Timestamp: time.Now(),
    })
    return err
}
```

### 3.2 发送消息（异步）

```go
func produceAsync(ctx context.Context, partitionKey string, payload []byte) error {
    producer, err := kafka.GetAsyncProducer(kafkaConfigKey)
    if err != nil {
        return err
    }
    msg := &kafka.ProducerMessage{
        Topic:     topicName,
        Key:       kafka.StringEncoder(partitionKey),
        Value:     kafka.ByteEncoder(payload),
        Timestamp: time.Now(),
    }
    // 将 ctx 注入 metadata，可在回调中通过 kafka.GetMessageContext 取出
    kafka.TracedProducerMessage(ctx, msg)
    producer.Input() <- msg
    return nil
}
```

> **注意**：异步模式需在调用方监听 `producer.Errors()` 和 `producer.Successes()` 处理结果。

---

## 4. 消费者

消费者在 `init()` 或 `application.OnInit` 阶段注册，frpc 框架自动启动。

### 4.1 简单处理函数（推荐入门）

```go
import (
    "context"

    "github.com/Shopify/sarama"
    "gitlab.futunn.com/infra/frpc/pkg/thirdparty/mq/kafka"
)

const (
    kafkaConfigKey   = "<config_key>"
    consumerKey      = "<consumer_key>"  // 对应 conf.toml consumers 下的子 key
)

func init() {
    _ = kafka.RegisterConsumer(kafkaConfigKey, consumerKey, handleMsg)
}

func handleMsg(
    ctx context.Context,
    session sarama.ConsumerGroupSession,
    msg *kafka.ConsumerMessage,
) error {
    // msg.Value  — 消息体（[]byte）
    // msg.Key    — 分区 key
    // msg.Topic  — topic 名
    // msg.Offset — 偏移量

    // 手动提交 offset（at-least-once 语义）
    session.MarkMessage(msg, "")
    return nil
}
```

### 4.2 组处理器（需要 Setup/Cleanup 钩子时使用）

```go
type MyConsumerHandler struct{}

func (h *MyConsumerHandler) Setup(session kafka.ConsumerGroupSession) error {
    // 每次 rebalance 后调用，可做初始化
    return nil
}

func (h *MyConsumerHandler) Cleanup(session kafka.ConsumerGroupSession) error {
    // rebalance 结束前调用，可做收尾
    return nil
}

func (h *MyConsumerHandler) HandleMsg(
    ctx context.Context,
    session kafka.ConsumerGroupSession,
    claim kafka.ConsumerGroupClaim,
    msg *kafka.ConsumerMessage,
) (needTerminateClaim bool, err error) {
    session.MarkMessage(msg, "")
    return false, nil
}

func init() {
    _ = kafka.RegisterConsumerEx(kafkaConfigKey, consumerKey, &MyConsumerHandler{})
}
```

### 4.3 分区处理器（需要每个分区独立状态时使用）

```go
type MyPartitionHandler struct {
    partition int32
}

func (h *MyPartitionHandler) HandleMsg(
    ctx context.Context,
    session kafka.ConsumerGroupSession,
    claim kafka.ConsumerGroupClaim,
    msg *kafka.ConsumerMessage,
) (needTerminateClaim bool, err error) {
    session.MarkMessage(msg, "")
    return false, nil
}

func (h *MyPartitionHandler) Destroy() error { return nil }

type MyTopicPartitionHandler struct{}

func (h *MyTopicPartitionHandler) Setup(session kafka.ConsumerGroupSession) error   { return nil }
func (h *MyTopicPartitionHandler) Cleanup(session kafka.ConsumerGroupSession) error { return nil }

func (h *MyTopicPartitionHandler) CreatePartitionMessageHandler(
    claim kafka.ConsumerGroupClaim,
) (kafka.PartitionMessageHandler, error) {
    return &MyPartitionHandler{partition: claim.Partition()}, nil
}

func init() {
    _ = kafka.RegisterTopicPartitionConsumer(kafkaConfigKey, consumerKey, &MyTopicPartitionHandler{})
}
```

---

## 5. 接入 Checklist

```
□ conf.toml 增加 [frpc.kafka.<config_key>] 连接配置
□ 需要生产：增加 [frpc.kafka.<config_key>.producer] 配置
□ 需要消费：增加 [frpc.kafka.<config_key>.consumers.<consumer_key>] 配置
□ 生产者：调用 kafka.GetSyncProducer / GetAsyncProducer + SendMessageContext
□ 消费者：在 init() 调用 kafka.RegisterConsumer / RegisterConsumerEx
□ 消费者 handler 中调用 session.MarkMessage(msg, "") 提交 offset
□ 添加埋点（metric.Alert / metric.Inc）覆盖错误和成功路径
□ 集成测试：加 //go:build integration tag，通过 application.Run 加载真实配置
```

---

## 6. 常见注意事项

| 问题 | 说明 |
|---|---|
| 不要缓存 producer | `GetSyncProducer` 每次返回框架管理的实例，直接调用即可 |
| offset 提交 | 调用 `session.MarkMessage` 后框架统一提交；漏调会导致重复消费 |
| at-least-once | handler 返回 `error` 不会自动重试，需业务侧幂等处理 |
| 分区顺序 | 同一 Key 保证落同一分区；跨分区无顺序保证 |
| rebalance | 新实例加入或摘除时触发，`Setup`/`Cleanup` 被调用，正常现象 |
| `disable_start_check = true` | 适合消费者 topic 尚未创建的场景；启动不报错，消费时才失败 |
| SASL 凭据 | 测试/生产环境账密不同，通过配置文件区分，禁止硬编码 |
| `fns://` 地址 | 依赖内网 FNS 服务发现，本地开发需 VPN 或换直连地址 |
