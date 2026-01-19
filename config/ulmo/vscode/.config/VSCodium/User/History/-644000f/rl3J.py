from typing import Literal
from random import choice, randint


def get_sign(x):
    if x == 0:
        return 0
    if x < 0:
        return -1
    if x > 0:
        return 1


type Sign = Literal[-1, 1]


def calc(a, b, c, signs: tuple[Sign, Sign] | None = None):
    if c % 4 != 0:
        return None

    num, denom = (-15 * a + b - c / 4), (a * b - 8)

    if denom == 0:
        return None

    if signs is not None:
        if (get_sign(num), get_sign(denom)) != signs:
            return None

    if num % denom != 0:
        return None

    return num / denom


LIMIT = 40

results = [None for _ in range(5)]
signs: list[tuple[Sign, Sign]] = [(1, 1), (-1, 1), (1, -1), (-1, -1)]

sign: tuple[Sign, Sign]
for res, sign in zip(results, signs):
    while res is None:
        a = choice([randint(-LIMIT, -2), randint(2, LIMIT)])
        b = choice([randint(-LIMIT, -2), randint(2, LIMIT)])
        c = choice([randint(-LIMIT, -2), randint(2, LIMIT)])
        res = calc(a, b, c)
    print(f"{a=:10}", f"{b=:10}", f"{c=:10}", f"{res=:10}", sep="|")
