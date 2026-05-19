# Metadata 构造 + 链路追踪初始化

## Metadata — `pkg/metadata`

`WithIncomingContextForTest` 模拟服务端收到请求场景，把 `*srpc.CRpcHead` 写入 Context 的 Incoming Metadata。

```go
import "gitlab.futunn.com/infra/frpc/pkg/metadata"

func TestWithMetadata(t *testing.T) {
    ctx := context.Background()
    uid := uint64(12345)

    ctx, err := metadata.WithIncomingContextForTest(ctx, &srpc.CRpcHead{
        OriginUid: &uid,
    })
    assert.NoError(t, err)

    md, ok := metadata.FromIncomingContext(ctx)
    assert.True(t, ok)
    inUid, ok := md.GetOriginUid()
    assert.True(t, ok)
    assert.EqualValues(t, uid, inUid)
}
```

特定字段可用 `WithOptionsContext`：
```go
ctx = metadata.WithOptionsContext(ctx, metadata.SetSessionId(sessionID))
md := metadata.GetAllForTest(ctx)
sid, ok := md.GetSessionId()
```

## 链路追踪 — `pkg/trace`

| 函数 | 说明 |
|---|---|
| `trace.InitForTest(sampleRate float64)` | 独立初始化 tracer，服务名 "go test" |
| `trace.InitSpanContextForTest(ctx)` | **推荐**，返回 `(span, ctx)`，需 `defer span.Finish()` |
| `trace.InitSpanForTest(ctx)` | 只返回 ctx，需手动取 span 调 Finish（不推荐） |

### 与 application.Run 配合（推荐）
TestMain 内 `application.OnInit(application.InitTracerGoTest(0.001))`，每个测试函数：
```go
func TestSomething(t *testing.T) {
    span, ctx := trace.InitSpanContextForTest(context.Background())
    defer span.Finish()
    // ...
}
```

### 独立初始化
不用 `application.Run` 时：
```go
trace.InitForTest(0.001)
span, ctx := trace.InitSpanContextForTest(context.Background())
defer span.Finish()
```

## 配置重置（隔离用）
```go
import "gitlab.futunn.com/infra/frpc/pkg/conf"

func TestConfigIsolation(t *testing.T) {
    conf.ResetDefaultConfigForTest()
    t.Cleanup(func() { conf.ResetDefaultConfigForTest() })
    // 加载测试专用配置 ...
}
```
注意：禁止在生产代码使用；reset 后必须重新获取 `*Config` 指针，缓存的旧指针失效。

## 日志（不用 application.Run 时）
```go
import "gitlab.futunn.com/infra/frpc/internal/observability/log"

log.InitForTest()                          // /dev/null, error 级
log.InitForTestWithTomlBytes(b []byte)     // 加载额外 TOML 配置
```
