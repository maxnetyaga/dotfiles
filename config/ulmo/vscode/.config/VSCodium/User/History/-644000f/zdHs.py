from typing import Literal


def sign(x):
    if x == 0:
        return 0
    if x < 0:
        return -1
    if x > 0:
        return 1

type Sign = Literal[0, -1, 1]
def calc(a, b, c, signs: tuple[Sign, Sign] | None = None):
    if c % 4 != 0:
        return False
    
    num, denom = (-15*a + b - c/4), (a*b - 8)

    if signs is not None:
        if (sign(num), sign(denom)) != signs:
            return False
    
    if num % denom != 0:
        return False
    
    return num / denom

LIMIT = 5_000_000
pos_range = range(2, LIMIT)
neg_range = range(-LIMIT, -1)

results = [None for i in range(5)]

for i in 