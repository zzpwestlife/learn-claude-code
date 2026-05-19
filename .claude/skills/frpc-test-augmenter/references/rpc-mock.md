# RPC Client Mock — `pkg/client/mock`

`pkg/client/mock` 提供全局 Mock 端点注册表。`ActivateForTest` 后，框架从注册表查 mock 端点而非发起真实 RPC。

## 核心 API
| 函数 | 说明 |
|---|---|
| `mock.ActivateForTest()` | 启用 Mock 模式 |
| `mock.DeactivateForTest()` | 停用并清空注册表 |
| `mock.RegisterForTest(serviceName, methodName, configKey, ep endpoint.Endpoint)` | 注册普通 RPC mock |
| `mock.RegisterStreamForTest(serviceName, methodName, configKey, stream)` | 注册流式 RPC mock |
| `mock.IsEnable()` | 检查 Mock 模式是否激活 |

`serviceName / methodName / configKey` 必须与业务调用处**完全一致**，否则 mock 不命中。

## 普通 RPC 用例
```go
import "gitlab.futunn.com/infra/frpc/pkg/client/mock"

func TestRPCCall(t *testing.T) {
    mock.ActivateForTest()
    defer mock.DeactivateForTest()

    mock.RegisterForTest("UserService", "GetUser", "default",
        func(ctx context.Context, req interface{}) (interface{}, error) {
            return &pb.GetUserResp{UserId: 123, UserName: "test_user"}, nil
        })

    resp, err := userClient.GetUser(ctx, &pb.GetUserReq{UserId: 123})
    assert.NoError(t, err)
    assert.Equal(t, "test_user", resp.UserName)
}
```

## 流式 RPC 用例
```go
mock.RegisterStreamForTest("ChatService", "StreamChat", "default", &mockStream{})
```
其中 `mockStream` 需实现 `streamingrpc.Stream` 接口。

## 常见错误
- mock 注册了但调用仍走真实链路 → 检查 `ActivateForTest` 是否调用，以及 service/method/configKey 三元组是否完全匹配。
- 包级 `Activate`/`Deactivate` 放 `TestMain` 即可全包共享；函数级则放 `t.Run` 内并 `defer Deactivate`。
