from mathutil.ops import add, mul, is_even, factorial


def test_add():
    assert add(2, 3) == 5
    assert add(-1, 1) == 0


def test_mul():
    assert mul(3, 4) == 12


def test_is_even():
    assert is_even(4) is True
    assert is_even(3) is False


def test_factorial():
    assert factorial(0) == 1
    assert factorial(3) == 6
    assert factorial(5) == 120
