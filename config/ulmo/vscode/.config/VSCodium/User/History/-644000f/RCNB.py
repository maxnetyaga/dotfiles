def sign(x):
    if x == 0:
        return 0
    if x < 0:
        return -1
    if x > 0:
        return 1

def calc(a, b, c, signs = None):
    if c % 4 != 0:
        return False
    
    if (-15*a + b - c/4) % (a*b - 8) != 0:
        return False
    
    return (-15*a + b - c/4) / (a*b - 8)

LIMIT = 5_000_000
pos_range = range(2, LIMIT)
neg_range = range(-LIMIT, -1)

results = [None for i in range(5)]

for i in 