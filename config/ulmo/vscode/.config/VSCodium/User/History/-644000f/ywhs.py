def calc(a, b, c):
    if c % 4 != 0:
        return False
    
    if (-15*a + b - c/4) % (a*b - 8) != 0:
        return False
    
    return (-15*a + b - c/4) / (a*b - 8)

