# RabbitMQ Mock — `pkg/thirdparty/mq/rmq`

`MockAcknowledger` 模拟消息确认器，所有方法**并发安全**。

## AckKind 常量
| 常量 | 值 | 说明 |
|---|---|---|
| `rmq.AckType` | `"ack"` | 确认 |
| `rmq.NackType` | `"nack"` | 否定确认 |
| `rmq.RejectType` | `"reject"` | 拒绝 |

## 操作方法
| 方法 | 说明 |
|---|---|
| `Ack(tag, multiple) error` | 记录一次 ack |
| `Nack(tag, multiple, requeue) error` | 记录一次 nack |
| `Reject(tag, requeue) error` | 记录一次 reject |

## 查询方法
| 方法 | 说明 |
|---|---|
| `IsAck() bool` | 是否发生过确认动作 |
| `GetAckKind() AckKind` | 最近一次类型 |
| `Tag() uint64` | 最近一次 delivery tag |
| `Multiple() bool` / `Requeue() bool` | 最近一次的标志位 |

## 用例
```go
import "gitlab.futunn.com/infra/frpc/pkg/thirdparty/mq/rmq"

func TestRMQHandler(t *testing.T) {
    acker := &rmq.MockAcknowledger{}

    delivery := amqp.Delivery{
        Body:         []byte(`{"order_id": 123}`),
        DeliveryTag:  100,
        Acknowledger: acker,
    }

    err := myHandler(ctx, &delivery)
    assert.NoError(t, err)

    assert.True(t, acker.IsAck())
    assert.Equal(t, rmq.AckType, acker.GetAckKind())
    assert.Equal(t, uint64(100), acker.Tag())
}
```
