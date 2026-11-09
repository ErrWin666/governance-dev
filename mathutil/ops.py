def add(a, b):
    return a + b


def mul(a, b):
    return a * b


def is_even(n):
    return n % 2 == 0


def factorial(n):
    r = 1
    for i in range(1, n + 1):
        r *= i
    return r
