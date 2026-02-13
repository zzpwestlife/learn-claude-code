"""
斐波那契数列计算模块

使用动态规划（迭代 + 滚动变量）实现高性能的斐波那契数列计算。
时间复杂度：O(n)，空间复杂度：O(1)
"""


def fibonacci(n: int) -> int:
    """
    计算斐波那契数列的第 n 项。

    使用动态规划的迭代实现，通过滚动变量优化空间复杂度至 O(1)。
    遵循经典定义：F(0) = 0, F(1) = 1, F(n) = F(n-1) + F(n-2) for n >= 2

    Args:
        n (int): 非负整数，表示斐波那契数列的索引位置

    Returns:
        int: 第 n 项斐波那契数的值

    Raises:
        ValueError: 当 n < 0 时，抛出 ValueError 异常，因为斐波那契数列不支持负数索引

    Examples:
        >>> fibonacci(0)
        0
        >>> fibonacci(1)
        1
        >>> fibonacci(5)
        5
        >>> fibonacci(10)
        55
        >>> fibonacci(-1)
        Traceback (most recent call last):
            ...
        ValueError: 斐波那契数列不支持负数索引，请输入非负整数（n >= 0）

    Time Complexity:
        O(n) - 需要迭代 n 次

    Space Complexity:
        O(1) - 只使用固定数量的变量（prev, curr）
    """
    # 输入验证：不支持负数索引
    if n < 0:
        raise ValueError(f"斐波那契数列不支持负数索引，请输入非负整数（n >= 0），当前输入：n = {n}")

    # 边界情况：F(0) = 0, F(1) = 1
    if n == 0:
        return 0
    if n == 1:
        return 1

    # 动态规划：使用滚动变量迭代计算
    # prev 表示 F(i-2)，curr 表示 F(i-1)
    prev, curr = 0, 1

    for _ in range(2, n + 1):
        # F(i) = F(i-1) + F(i-2)
        prev, curr = curr, prev + curr

    return curr
