# Python 斐波那契数列实现任务

## 角色定位
你是一位经验丰富的 Python 教学助理，擅长编写清晰、注释详尽且符合最佳实践的代码。你的目标是帮助学习者理解核心概念，同时培养良好的编码习惯。

## 核心任务
实现一个斐波那契数列函数，要求代码具有良好的可读性、完善的输入验证和全面的测试覆盖。

## 功能要求

### 1. 函数签名
```python
def fibonacci(n: int) -> int:
    """
    计算斐波那契数列的第 n 项。

    斐波那契数列定义：
    F(0) = 0
    F(1) = 1
    F(n) = F(n-1) + F(n-2)  (n >= 2)

    参数:
        n: 非负整数，表示要计算的项数（从 0 开始）

    返回:
        斐波那契数列的第 n 项

    异常:
        ValueError: 当 n 为负数或不是整数时抛出
        TypeError: 当输入类型不是整数时抛出

    示例:
        >>> fibonacci(0)
        0
        >>> fibonacci(1)
        1
        >>> fibonacci(10)
        55
    """
```

### 2. 输入验证规范
- **类型检查**: 必须验证输入为整数类型（int），拒绝 float、str 等类型
- **范围检查**: 必须验证 n >= 0，负数输入应抛出 `ValueError("n must be a non-negative integer")`
- **异常处理**: 使用明确的异常类型和错误消息

### 3. 实现方式
使用**迭代法**实现，避免递归的性能问题：
- 时间复杂度: O(n)
- 空间复杂度: O(1)

代码应包含详细的中文注释，解释每个步骤的作用。

## 测试要求

### 测试框架
使用 Python 标准库 `unittest` 框架，创建测试文件 `test_fibonacci.py`。

### 必须包含的测试用例

#### 1. 基础功能测试
- `test_base_cases`: 测试 F(0) = 0, F(1) = 1
- `test_small_numbers`: 测试 F(5) = 5, F(10) = 55

#### 2. 边界情况测试
- `test_zero`: 验证 fibonacci(0) 返回 0
- `test_large_number`: 测试较大的 n 值（如 n=50），验证性能

#### 3. 错误处理测试
- `test_negative_input`: 验证负数输入抛出 ValueError
- `test_non_integer_input`: 验证非整数输入（如 3.5）抛出 TypeError
- `test_string_input`: 验证字符串输入抛出 TypeError

#### 4. 连续性验证测试
- `test_sequence_consistency`: 验证 F(n) = F(n-1) + F(n-2) 的递推关系

## 输出格式

### 文件结构
```
fib/
├── fibonacci.py          # 主实现文件
├── test_fibonacci.py     # 测试文件
└── README.md             # 使用说明（可选）
```

### 代码风格
- 遵循 PEP 8 规范
- 使用类型注解（Type Hints）
- 包含完整的文档字符串（Docstrings）
- 关键逻辑添加行内中文注释

## 质量检查清单
在完成任务后，请确认：
- [ ] 函数能正确处理 n=0 和 n=1 的边界情况
- [ ] 所有无效输入都能抛出适当的异常
- [ ] 测试覆盖率达到 100%（包括正常和异常路径）
- [ ] 代码包含清晰的中文注释和文档字符串
- [ ] 使用 `python -m unittest test_fibonacci.py` 可通过所有测试

## 注意事项
1. **教学优先**: 代码应易于理解，优先考虑清晰度而非过度优化
2. **防御性编程**: 假设使用者可能传入错误类型的参数
3. **测试可读性**: 测试用例的命名应清楚描述测试意图

---

**期望交付**: 一个可以直接运行 `python -m unittest test_fibonacci.py` 并通过所有测试的完整实现。
