# UltraWork 激活模板

## 标准 UltraWork 激活提示词

```
ULTRAWORK MODE ENABLED!

## ABSOLUTE CERTAINTY REQUIRED - DO NOT SKIP THIS

**我必须100%确定才能开始实施。**

### 规格定义 (必须先阅读并理解)

请阅读并确认理解以下规格定义:

```json
{
  "successCriteria": {
    "functional": [
      {
        "id": "F001",
        "requirement": "用户注册",
        "endpoint": "POST /auth/register",
        "expected": {
          "statusCode": 201,
          "body": {
            "id": "uuid",
            "email": "user@example.com",
            "name": "string"
          }
        }
      }
    ],
    "observable": [
      {
        "id": "O001",
        "requirement": "HTTP状态码正确",
        "criteria": "成功请求返回2xx"
      }
    ],
    "passFail": [
      {
        "id": "P001",
        "test": "make test",
        "criteria": "退出码为0"
      }
    ]
  }
}
```

### 完整规格文件

请阅读完整规格文件: `examples/ultrawork-complete-demo/spec.json`

### 我需要你确认以下几点 (回复并确认):

1. ✅ **我完全理解**需要实现什么功能:
   - 用户认证 REST API (注册/登录/刷新/获取信息)

2. ✅ **我完全理解**成功标准:
   - Functional: 4个API端点功能正常
   - Observable: HTTP状态码和响应格式正确
   - Pass/Fail: 测试命令全部通过

3. ✅ **我完全理解**约束条件:
   - 安全性: bcrypt, JWT, 环境变量
   - 性能: <200ms响应时间
   - 代码质量: >80%覆盖率

4. ✅ **我完全理解**测试计划:
   - 6个测试用例
   - 执行方式: `make integration-test`

### 在你确认以上所有点之前，请勿开始实施。

---

**确认格式 (复制并填写):**

```
我确认理解规格定义:

1. ✅ 功能需求: [用自己的话复述]
2. ✅ 成功标准: [列出关键指标]
3. ✅ 约束条件: [列出安全/性能/质量要求]
4. ✅ 测试计划: [列出测试用例和执行方式]

我已准备好继续到规划阶段。
```
