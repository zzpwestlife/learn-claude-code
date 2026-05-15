# INPUT: None (tests only)
# OUTPUT: unittest pass/fail
# POS: tests/test_password_gen.py

import subprocess
import sys
import unittest

from scripts.password_gen import generate

ALPHABET = set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")


class PasswordGenTests(unittest.TestCase):
    def test_default_length(self) -> None:
        """Scenario 1: 默认生成 16 位密码，字符全属于 [a-zA-Z0-9]"""
        pwd = generate()
        self.assertEqual(16, len(pwd))
        self.assertTrue(all(char in ALPHABET for char in pwd))

    def test_custom_length(self) -> None:
        """Scenario 2: 指定长度 24"""
        pwd = generate(length=24)
        self.assertEqual(24, len(pwd))
        self.assertTrue(all(char in ALPHABET for char in pwd))

    def test_randomness(self) -> None:
        """Scenario 3: 两次调用结果不同（密码安全随机）"""
        self.assertNotEqual(generate(), generate())

    def test_invalid_length_zero(self) -> None:
        """Scenario 4a: length=0 应抛出 ValueError"""
        with self.assertRaises(ValueError):
            generate(length=0)

    def test_invalid_length_negative(self) -> None:
        """Scenario 4b: length=-1 应抛出 ValueError"""
        with self.assertRaises(ValueError):
            generate(length=-1)

    def test_cli_default(self) -> None:
        """CLI 默认调用输出 16 位字符，退出码 0"""
        result = subprocess.run([sys.executable, "scripts/password_gen.py"], capture_output=True, text=True, check=False)
        self.assertEqual(0, result.returncode)
        output = result.stdout.strip()
        self.assertEqual(16, len(output))
        self.assertTrue(all(char in ALPHABET for char in output))

    def test_cli_custom_length(self) -> None:
        """CLI --length 8 输出 8 位字符"""
        result = subprocess.run(
            [sys.executable, "scripts/password_gen.py", "--length", "8"],
            capture_output=True,
            text=True,
            check=False,
        )
        self.assertEqual(0, result.returncode)
        self.assertEqual(8, len(result.stdout.strip()))


if __name__ == "__main__":
    unittest.main()
