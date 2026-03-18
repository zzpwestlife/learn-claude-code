# Best Practices — Python CLI 密码生成器

## 安全性

### 为何使用 `secrets` 而非 `random`

| 维度 | `random` | `secrets` |
|------|----------|-----------|
| 算法 | 梅森旋转（伪随机，MT19937） | OS CSPRNG（`/dev/urandom`） |
| 可预测性 | 知道种子即可预测所有后续值 | 不可预测 |
| 适用场景 | 模拟、游戏、统计采样 | 密码、Token、会话 ID |
| Python 文档 | 不推荐用于安全场景 | 官方推荐用于安全场景 |

**结论**：密码生成器**必须**使用 `secrets.choice()`，而非 `random.choice()`。

### 字符集设计注意事项

- **特殊字符集**：使用 `string.punctuation`（32 个标准 ASCII 标点），覆盖常见网站的密码要求
- **避免自定义过滤**：不要额外排除"歧义字符"（0/O/l/1），保持最大熵值，此为 Out of Scope
- **字符集均等权重**：`secrets.choice(charset)` 已保证每个字符等概率，无需额外加权

---

## 代码质量

### 关注点分离（SoC）

```python
# ✅ 正确：生成函数不做 I/O
def generate_password(charset: str, length: int) -> str:
    return "".join(secrets.choice(charset) for _ in range(length))

# ❌ 错误：不应在生成函数中 print 或 sys.exit
def generate_password(...):
    print(...)  # 禁止
```

### 错误处理模式

```python
# ✅ 在 main() 统一捕获，友好输出
def main() -> int:
    try:
        charset = build_charset(args)
    except ValueError as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1
    ...
    return 0
```

### 入口模式

```python
# ✅ 项目标准入口模式
if __name__ == "__main__":
    raise SystemExit(main())
```

### 类型注解规范

```python
# ✅ 所有函数必须有完整类型注解
def build_charset(args: argparse.Namespace) -> str: ...
def generate_password(charset: str, length: int) -> str: ...
def parse_args() -> argparse.Namespace: ...
def main() -> int: ...
```

---

## 性能与可移植性

- **跨平台**：`secrets` 在 macOS（`/dev/urandom`）和 Linux（`/dev/urandom`）均可用，Python 3.6+
- **无状态**：每次调用独立，无全局状态
- **速度**：`secrets.choice` 对于 < 1000 字符的密码生成可忽略不计的延迟

---

## 文件规范检查清单

- [ ] 文件头 3 行 metadata（INPUT / OUTPUT / POS）
- [ ] 文件总行数 < 200
- [ ] 每个函数行数 < 20
- [ ] 所有函数有类型注解
- [ ] 无 `import random`（只用 `secrets`）
- [ ] 无注释掉的代码
- [ ] 无硬编码路径
