# kafka-frpc (Skill)

在 **frpc Go 项目**中接入 Kafka 的向导。覆盖：多地区 conf.toml 配置速查、生产者/消费者代码模板、接入 Checklist。

---

## 触发词

```
接入 kafka / 新增 kafka 消费者 / kafka 生产者
add kafka consumer / kafka producer / kafka frpc 配置
```

示例：
- ✅ "帮我在 HK 的 frpc 项目里接入一个 Kafka 消费者"
- ✅ "给 SG 服务加个 Kafka 生产者，往 OrderEvents topic 发消息"

---

## 接入流程

| Step | 说明 |
|---|---|
| 0 现状探查 | 搜索项目已有 Kafka 配置，了解命名风格 |
| 1 需求采集 | 确认环境（本地/线上）、地区、用途（生产者/消费者/双向）、topic、config_key、group id |
| 2 配置输出 | 按地区速查表生成 conf.toml 配置块，确认后写入 `conf/conf.toml` |
| 2.5 配置确认 | 用户确认 config_key / topic / group id 无误 |
| 3 代码输出 | 生产者（`GetSyncProducer`）/ 消费者（`RegisterConsumer`）代码，替换占位符 |
| 4 Checklist | 逐项引导验收 |

---

## 支持地区

AU · CA · HK · HKVA · JP · MY · SG · TH · US · USVA

各地区鉴权模式：
- **AWS MSK**（AU/CA）：TLS 必须开启，端口 9096，SCRAM-SHA-512
- **腾讯云 CKafka**（HK/HKVA/JP/SG/TH/US/USVA）：TLS 不能开启，端口 9092，SCRAM-SHA-256
- **阿里云 AliKafka**（MY）：无鉴权，PLAINTEXT

> 密码向 joeyzou 获取（告知：地区 + topic + 读/写权限）。

---

## 常见坑

| 现象 | 原因 | 解决 |
|---|---|---|
| `SASL Error 34` | AWS MSK 需先 TLS 握手 | `net.tls.enable = true` |
| CKafka TLS 握手失败 | 腾讯云不支持 TLS | 删除 `net.tls.enable` |
| 消费者重复消费 | 未调用 `MarkMessage` | 加 `defer session.MarkMessage(msg, "")` |
| 本地无法连 `fns://` | FNS 依赖内网 | 改为直连 IP:port |

---

## 不适用场景

- 非 frpc 框架（原生 sarama、confluent-kafka 等）→ 直接给原生用法
- 搭建 / 运维 Kafka 集群 → 超出范围
- 生产环境鉴权配置 → 联系 joeyzou
- 地区不在速查表 → 使用通用模板，提示用户确认鉴权方式
