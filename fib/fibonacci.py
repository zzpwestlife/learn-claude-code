"""
斐波那契数列实现模块

本模块实现了一个教学级的斐波那契数列函数，强调代码可读性、
输入验证和最佳实践演示。
"""


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
        TypeError: 当输入不是整数类型时抛出（包括布尔值）
        ValueError: 当 n 为负数时抛出

    示例:
        >>> fibonacci(0)
        0
        >>> fibonacci(1)
        1
        >>> fibonacci(10)
        55
        >>> fibonacci(20)
        6765
    """
    # ===== 类型检查 =====
    # 额外检查：明确排除布尔值
    # 虽然 bool 是 int 的子类，但 fibonacci(True) 在语义上是不合理的
    # 必须先检查 bool，因为 type(True) 是 bool，不是 int
    if isinstance(n, bool):
        raise TypeError("n must be an integer, not boolean")

    # 使用 type() 而非 isinstance() 来严格检查整数类型
    if type(n) is not int:
        raise TypeError("n must be an integer")

    # ===== 范围检查 =====
    # 验证 n 是非负整数
    if n < 0:
        raise ValueError("n must be a non-negative integer")

    # ===== 边界情况处理 =====
    # F(0) = 0 是数列的起点
    if n == 0:
        return 0

    # F(1) = 1 是第二个值
    if n == 1:
        return 1

    # ===== 迭代计算 =====
    # 使用两个变量保存前两项，避免递归的性能问题
    # 时间复杂度: O(n)
    # 空间复杂度: O(1)
    prev, curr = 0, 1  # prev = F(i-2), curr = F(i-1)

    # 从第 2 项开始迭代计算
    for _ in range(2, n + 1):
        # 更新：新的当前值 = 前两项之和
        # 同时更新 prev 为旧的 curr
        prev, curr = curr, prev + curr

    return curr
