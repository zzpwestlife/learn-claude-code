# INPUT: --length (optional, default=16)
# OUTPUT: single password string printed to stdout
# POS: scripts/password_gen.py

import argparse
import secrets
import string

ALPHABET: str = string.ascii_letters + string.digits  # 62 chars: a-z A-Z 0-9


def generate(length: int = 16) -> str:
    """Return a cryptographically secure random password of given length."""
    if length < 1:
        raise ValueError(f"length must be >= 1, got {length}")
    return "".join(secrets.choice(ALPHABET) for _ in range(length))


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate a secure random password.")
    parser.add_argument(
        "--length", type=int, default=16,
        help="Password length (default: 16, min: 1)"
    )
    args = parser.parse_args()
    if args.length < 1:
        parser.error(f"--length must be >= 1, got {args.length}")
    print(generate(length=args.length))


if __name__ == "__main__":
    main()
