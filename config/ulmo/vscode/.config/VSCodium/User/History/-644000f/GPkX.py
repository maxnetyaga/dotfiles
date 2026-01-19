from typing import Literal
from random import randint

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
        return None
    
    num, denom = (-15*a + b - c/4), (a*b - 8)

    if signs is not None:
        if (sign(num), sign(denom)) != signs:
            return None
    
    if num % denom != 0:
        return None
    
    return num / denom

LIMIT = 5_000_000

results = [None for i in range(5)]

for i in results:
    while 