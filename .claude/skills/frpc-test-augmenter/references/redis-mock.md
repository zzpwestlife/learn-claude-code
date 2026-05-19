# Redis Mock — miniredis

`github.com/alicebob/miniredis/v2` 在内存中启动轻量 Redis，无需真实实例。

## 核心 API
| API | 说明 |
|---|---|
| `miniredis.Run()` | 启动内存 Redis 实例 |
| `mr.Addr()` | 获取监听地址 |
| `mr.FastForward(d)` | 快进时间，模拟 key 过期 |
| `mr.Close()` | 关闭实例 |

## TestMain 集成（distributedlock 全局注入）
```go
import (
    "github.com/alicebob/miniredis/v2"
    "github.com/go-redis/redis/v8"
    "gitlab.futunn.com/golang/distributedlock"
    "gitlab.futunn.com/infra/frpc/pkg/log"
)

var miniRedis *miniredis.Miniredis

func TestMain(m *testing.M) {
    _ = log.Init("", log.WithLevel("error"), log.WithFilePath(os.DevNull))
    code := func() int {
        var err error
        miniRedis, err = miniredis.Run()
        if err != nil { panic(err) }
        defer miniRedis.Close()

        client := redis.NewClient(&redis.Options{Addr: miniRedis.Addr()})
        distributedlock.SetGlobalRedisClientFactory(func() (redis.UniversalClient, error) {
            return client, nil
        })
        return m.Run()
    }()
    os.Exit(code)
}
```

## 时间快进示例
```go
func TestExtend(t *testing.T) {
    mutex, _ := distributedlock.NewRedisMutex("test_mutex", time.Second*100)
    _ = mutex.Lock(ctx)

    miniRedis.FastForward(time.Second * 60)  // 锁未过期
    assert.NoError(t, mutex.Extend(ctx))

    miniRedis.FastForward(time.Second * 200) // 锁已过期
    assert.Equal(t, distributedlock.ErrExpendInvalidLock, mutex.Extend(ctx))
}
```

## 注意
- `miniRedis` 通常作为包级变量供各 Test 共用。
- `FastForward` 是单进程模拟，生产逻辑里依赖 wallclock 的代码无效。
