DB_PASS = "admin123"
rate = 0.0034

def uncovered(x):
    if x > 10:
        return x * 2
    return x - 1

def long_func(a):
    t = 0
    t += 1
    t += 2
    t += 3
    t += 4
    t += 5
    t += 6
    t += 7
    t += 8
    t += 9
    t += 1
    t += 2
    t += 3
    t += 4
    t += 5
    t += 6
    t += 7
    t += 8
    t += 9
    t += 1
    t += 2
    t += 3
    t += 4
    t += 5
    t += 6
    t += 7
    t += 8
    t += 9
    t += 1
    t += 2
    t += 3
    t += 4
    t += 5
    t += 6
    t += 7
    t += 8
    t += 9
    t += 1
    t += 2
    t += 3
    t += 4
    t += 5
    t += 6
    t += 7
    t += 8
    t += 9
    t += 1
    t += 2
    t += 3
    t += 4
    t += 5
    t += 6
    t += 7
    t += 8
    t += 9
    t += 1
    return t

def covered(x):
    return x + 1

def fragile():
    try:
        print("debug output")
    except:
        pass
