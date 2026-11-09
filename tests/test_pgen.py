import string
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "src"))

import pytest
from pgen import build_alphabet, generate, main


def test_alphabet_with_symbols_has_letters_digits_symbols():
    a = build_alphabet(no_symbols=False)
    assert set(string.ascii_letters + string.digits) <= set(a)
    assert any(c in string.punctuation for c in a)


def test_alphabet_no_symbols_is_alnum_only():
    a = build_alphabet(no_symbols=True)
    assert set(a) == set(string.ascii_letters + string.digits)


def test_generate_length_matches():
    a = build_alphabet(False)
    for n in (8, 20, 128):
        assert len(generate(n, a)) == n


def test_generate_chars_in_pool():
    a = "abc123"
    assert set(generate(500, a)) <= set(a)


def test_generate_empty_alphabet_raises():
    with pytest.raises(ValueError):
        generate(8, "")


def test_generate_unique_per_call():
    a = build_alphabet(False)
    assert generate(20, a) != generate(20, a)


def test_main_help_exits_zero(capsys):
    with pytest.raises(SystemExit) as e:
        main(["--help"])
    assert e.value.code == 0


def test_main_defaults_print_one_password(capsys):
    assert main([]) == 0
    out = capsys.readouterr().out.strip().splitlines()
    assert len(out) == 1 and len(out[0]) == 20


def test_main_count_and_no_symbols(capsys):
    assert main(["--count", "3", "--no-symbols"]) == 0
    out = capsys.readouterr().out.strip().splitlines()
    assert len(out) == 3
    assert all(p.isalnum() for p in out)


def test_main_rejects_bad_length():
    with pytest.raises(SystemExit):
        main(["--length", "4"])
    with pytest.raises(SystemExit):
        main(["--length", "999"])


def test_main_rejects_bad_count():
    with pytest.raises(SystemExit):
        main(["--count", "0"])
