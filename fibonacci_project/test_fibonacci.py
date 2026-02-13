"""
测试斐波那契函数的完整测试套件

遵循 TDD 原则，覆盖以下场景：
1. 边界情况：F(0), F(1)
2. 常规情况：F(5), F(10), F(20)
3. 异常情况：负数输入
4. 性能测试：F(100)（验证不超时）
"""

import pytest
from fibonacci import fibonacci


class TestFibonacciBaseCases:
    """测试斐波那契数列的基础情况"""

    def test_fibonacci_zero(self):
        """测试 F(0) = 0"""
        assert fibonacci(0) == 0

    def test_fibonacci_one(self):
        """测试 F(1) = 1"""
        assert fibonacci(1) == 1


class TestFibonacciNormalCases:
    """测试斐波那契数列的常规情况"""

    def test_fibonacci_small_number(self):
        """测试小数值：F(5) = 5"""
        assert fibonacci(5) == 5

    def test_fibonacci_medium_number(self):
        """测试中等数值：F(10) = 55"""
        assert fibonacci(10) == 55

    def test_fibonacci_larger_number(self):
        """测试较大数值：F(20) = 6765"""
        assert fibonacci(20) == 6765


class TestFibonacciExceptionCases:
    """测试异常输入的处理"""

    def test_fibonacci_negative_small(self):
        """测试小负数输入应抛出 ValueError"""
        with pytest.raises(ValueError, match=".*负数.*|.*negative.*"):
            fibonacci(-1)

    def test_fibonacci_negative_large(self):
        """测试大负数输入应抛出 ValueError"""
        with pytest.raises(ValueError, match=".*负数.*|.*negative.*"):
            fibonacci(-10)


class TestFibonacciPerformance:
    """测试性能相关场景"""

    def test_fibonacci_large_number_no_timeout(self):
        """测试 F(100) 不会超时（验证非递归实现）"""
        result = fibonacci(100)
        assert result == 354224848179261915075  # F(100) 的正确值

    def test_fibonacci_sequence_consistency(self):
        """测试数列的连续性：F(n) = F(n-1) + F(n-2)"""
        for n in range(2, 15):
            assert fibonacci(n) == fibonacci(n-1) + fibonacci(n-2)
