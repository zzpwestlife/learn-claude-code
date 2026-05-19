# HTTP Mock — httptest 优先 / httpmock 兜底

| 方式 | 适用 | 特点 |
|---|---|---|
| `net/http/httptest` | 服务地址可注入 | 创建真实 TCP 连接，覆盖更真实，无第三方依赖 |
| `github.com/jarcoal/httpmock` | URL 在业务代码硬编码无法替换 | Transport 层拦截，零侵入 |

**优先 httptest**。仅当被测代码硬编码外部 URL 时才用 httpmock。

## httptest 用例
```go
import (
    "net/http"
    "net/http/httptest"
    frpchttp "gitlab.futunn.com/infra/frpc/pkg/http"
)

func TestHTTPClient(t *testing.T) {
    server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Type", "application/json")
        w.WriteHeader(http.StatusOK)
        w.Write([]byte(`{"code":0,"msg":"ok"}`))
    }))
    defer server.Close()

    resp, err := frpchttp.Get(ctx, server.URL)
    assert.NoError(t, err)
    assert.Equal(t, http.StatusOK, resp.StatusCode)
}
```

## HTTP Handler 测试 (httptest.NewRecorder)
```go
req := httptest.NewRequest(http.MethodPost, "/api/v1/user", bytes.NewReader(requestBody))
req.Header.Set("Content-Type", "application/json")
w := httptest.NewRecorder()
router.ServeHTTP(w, req)
assert.Equal(t, http.StatusOK, w.Code)
```

## httpmock 用例（兜底）
```go
import "github.com/jarcoal/httpmock"

func TestExternalAPI(t *testing.T) {
    httpmock.Activate()
    defer httpmock.DeactivateAndReset()

    httpmock.RegisterResponder("GET", "https://api.third-party.com/data",
        httpmock.NewJsonResponderOrPanic(200, map[string]interface{}{"code": 0}))

    result, err := myService.FetchData(ctx)
    assert.NoError(t, err)
    assert.Equal(t, 1, httpmock.GetTotalCallCount())
}
```
