import pytest
from demo_math import add, multiply


class TestAdd:
    """Tests for the add function."""

    @pytest.mark.parametrize(
        "a,b,expected",
        [
            (2, 3, 5),
            (-1, 1, 0),
            (0, 0, 0),
            (1.5, 2.5, 4.0),
        ],
    )
    def test_add(self, a, b, expected):
        """Test add function with various inputs."""
        assert add(a, b) == expected


class TestMultiply:
    """Tests for the multiply function."""

    @pytest.mark.parametrize(
        "a,b,expected",
        [
            (3, 4, 12),  # 整数乘法
            (2.5, 4, 10.0),  # 浮点数与整数混合
            (-3, 7, -21),  # 负数乘法
            (0, 100, 0),  # 零值边界
            (-2.5, -4, 10.0),  # 双负数
            (1, 1, 1),  # 单位元素
        ],
    )
    def test_multiply(self, a, b, expected):
        """Test multiply function with various inputs."""
        assert multiply(a, b) == expected
