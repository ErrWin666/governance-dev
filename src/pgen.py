import argparse
import secrets
import string
import sys

DEFAULT_LENGTH = 20
MIN_LENGTH = 8
MAX_LENGTH = 128


def build_alphabet(no_symbols: bool) -> str:
    pool = string.ascii_letters + string.digits
    if not no_symbols:
        pool += "!@#$%^&*()-_=+[]{}<>?"
    return pool


def generate(length: int, alphabet: str) -> str:
    if not alphabet:
        raise ValueError("alphabet must not be empty")
    return "".join(secrets.choice(alphabet) for _ in range(length))


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(prog="pgen", description="CLI password generator")
    parser.add_argument("--length", type=int, default=DEFAULT_LENGTH,
                        help=f"password length {MIN_LENGTH}-{MAX_LENGTH} (default {DEFAULT_LENGTH})")
    parser.add_argument("--no-symbols", action="store_true", help="letters+digits only")
    parser.add_argument("--count", type=int, default=1, help="number of passwords (default 1)")
    args = parser.parse_args(argv)

    if not MIN_LENGTH <= args.length <= MAX_LENGTH:
        parser.error(f"--length must be {MIN_LENGTH}-{MAX_LENGTH}")
    if args.count < 1:
        parser.error("--count must be >= 1")

    alphabet = build_alphabet(args.no_symbols)
    for _ in range(args.count):
        print(generate(args.length, alphabet))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
