import risky_pkg.b as b

def dead():
    return 1
    y = 42
    return y

def complex_one(a, b, c, d, e):
    r = 0
    for i in range(10):
        if a:
            if b:
                if c:
                    if d:
                        if e:
                            r += 1
                        else:
                            r += 2
                    else:
                        r += 3
                else:
                    r += 4
            else:
                r += 5
        else:
            r += 6
    return r
