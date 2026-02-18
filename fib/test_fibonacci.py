"""
斐波那契函数单元测试

本测试模块使用 unittest 框架对 fibonacci 函数进行全面测试，
覆盖所有正常路径和异常情况。
"""

import unittest
from fibonacci import fibonacci


class TestFibonacci(unittest.TestCase):
    """斐波那契函数测试套件"""

    def test_base_cases(self):
        """测试基础情况 F(0) 和 F(1)"""
        self.assertEqual(fibonacci(0), 0, "F(0) 应该等于 0")
        self.assertEqual(fibonacci(1), 1, "F(1) 应该等于 1")

    def test_small_numbers(self):
        """测试小数值 F(5) 和 F(10)"""
        self.assertEqual(fibonacci(5), 5, "F(5) 应该等于 5")
        self.assertEqual(fibonacci(10), 55, "F(10) 应该等于 55")

    def test_zero(self):
        """测试边界情况 F(0)"""
        self.assertEqual(fibonacci(0), 0, "F(0) 应该等于 0")

    def test_large_number(self):
        """测试较大数值 F(50)，验证性能和正确性"""
        # F(50) = 12586269025
        # 这个测试验证算法的性能和正确性
        expected = 12586269025
        result = fibonacci(50)
        self.assertEqual(result, expected, f"F(50) 应该等于 {expected}")

    def test_negative_input(self):
        """测试负数输入抛出 ValueError"""
        with self.assertRaises(ValueError) as context:
            fibonacci(-1)
        self.assertEqual(str(context.exception), "n must be a non-negative integer")

        with self.assertRaises(ValueError) as context:
            fibonacci(-100)
        self.assertEqual(str(context.exception), "n must be a non-negative integer")

    def test_float_input(self):
        """测试浮点数输入抛出 TypeError"""
        with self.assertRaises(TypeError) as context:
            fibonacci(3.14)
        self.assertEqual(str(context.exception), "n must be an integer")

        with self.assertRaises(TypeError) as context:
            fibonacci(0.0)
        self.assertEqual(str(context.exception), "n must be an integer")

    def test_string_input(self):
        """测试字符串输入抛出 TypeError"""
        with self.assertRaises(TypeError) as context:
            fibonacci("10")
        self.assertEqual(str(context.exception), "n must be an integer")

        with self.assertRaises(TypeError) as context:
            fibonacci("hello")
        self.assertEqual(str(context.exception), "n must be an integer")

    def test_boolean_input(self):
        """测试布尔值输入抛出 TypeError（边界情况）"""
        # bool 是 int 的子类，但 fibonacci(True) 在语义上不合理
        with self.assertRaises(TypeError) as context:
            fibonacci(True)
        self.assertEqual(str(context.exception), "n must be an integer, not boolean")

        with self.assertRaises(TypeError) as context:
            fibonacci(False)
        self.assertEqual(str(context.exception), "n must be an integer, not boolean")

    def test_sequence_consistency(self):
        """测试递推关系 F(n) = F(n-1) + F(n-2)"""
        # 验证斐波那契数列的递推性质
        for n in range(2, 20):
            result = fibonacci(n)
            expected = fibonacci(n - 1) + fibonacci(n - 2)
            self.assertEqual(result, expected, f"F({n}) = F({n-1}) + F({n-2}) 应该成立")

    def test_medium_numbers(self):
        """测试中等数值，验证算法正确性"""
        self.assertEqual(fibonacci(15), 610, "F(15) 应该等于 610")
        self.assertEqual(fibonacci(20), 6765, "F(20) 应该等于 6765")
        self.assertEqual(fibonacci(25), 75025, "F(25) 应该等于 75025")


if __name__ == '__main__':
    # 运行测试套件
    unittest.main(verbosity=2)
