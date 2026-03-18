# 架构说明 - 密码生成器

## 文件结构

```
learn-claude-code/
├── scripts/
│   └── passgen.py          # 主工具文件（新建）
└── tests/
    └── test_passgen.py     # 单元测试（新建）
```

## 模块设计

### `scripts/passgen.py`（< 200 行）

```
文件头（3行强制元数据）
│
├── 常量
│   └── CHARSETS: dict[str, str]   # 各字符集定义
│
├── build_charsets(args) -> dict[str, str]
│   # 根据 CLI 参数构建 {类别名: 字符串} 字典（仅启用的类别）
│
├── generate_password(length, charsets: dict[str, str]) -> str
│   # 保证每类至少1字符，再随机填充合并池，shuffle 打乱
│
├── parse_args() -> Namespace      # argparse 定义与验证
│
└── main() -> None                 # 入口，调用以上函数并打印结果
```

## 数据流

```
CLI 参数
    │
    ▼
parse_args()
    │
    ├── 验证 length >= 4
    ├── 验证至少一个字符集启用
    │
    ▼
generate_password()
    │
    ├── 为每类取 1 个 secrets.choice() 字符
    ├── 填充剩余字符（从合并池 secrets.choice()）
    ├── SystemRandom().shuffle()
    │
    ▼
print(password)  →  stdout
```

## 依赖关系

| 模块 | 用途 | 类型 |
|------|------|------|
| `secrets` | 密码学安全随机数生成 | 标准库 |
| `string`  | 字符集常量（`ascii_uppercase` 等） | 标准库 |
| `argparse`| CLI 参数解析 | 标准库 |
| `sys`     | `sys.exit()` 错误退出 | 标准库 |

**零第三方依赖。**
