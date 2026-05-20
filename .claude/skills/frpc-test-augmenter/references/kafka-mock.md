# Kafka Mock — `pkg/thirdparty/mq/kafka`

模拟 `sarama.ConsumerGroupSession`，用于测试 MsgHandler。

## 构造函数
```go
func NewMockConsumerGroupSession(
    ctx context.Context,
    claims map[string][]int32,
    memberID string,
    generationID int32,
) *MockConsumerGroupSession
```

## 实现的接口方法
| 方法 | 说明 |
|---|---|
| `Claims() map[string][]int32` | 返回 claimed 分区 |
| `MemberID() string` | 成员 ID |
| `GenerationID() int32` | 代际 ID |
| `Context() context.Context` | 返回 ctx |
| `MarkOffset / Commit / ResetOffset / MarkMessage` | 全部为空实现 |

## 用例
```go
import "gitlab.futunn.com/infra/frpc/pkg/thirdparty/mq/kafka"

func TestKafkaConsumer(t *testing.T) {
    ctx := context.Background()
    session := kafka.NewMockConsumerGroupSession(
        ctx,
        map[string][]int32{"my_topic": {0, 1, 2}},
        "test-member-1",
        1,
    )

    msg := &kafka.ConsumerMessage{
        Topic: "my_topic", Partition: 0, Offset: 100,
        Value: []byte(`{"key":"value"}`),
    }

    err := myHandler(ctx, session, msg)
    assert.NoError(t, err)
}
```

## 弃用提示
`kafka.StartConsumerForTest(kafkaConfigKey, consumerConfigKey)` 已废弃，**不要使用**。改在 TestMain 用 `application.Run` 让框架按 `conf/conf.toml` 自动启 Consumer。
