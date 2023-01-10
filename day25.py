import itertools as it
import functools as ft
from collections import defaultdict, Counter, deque
import re
import math
import array

lines = open(0).read().strip().splitlines()


def decode(s):
    translation = {
        "=": -2,
        "-": -1,
        "0": 0,
        "1": 1,
        "2": 2,
    }
    result = 0
    place = 0
    for c in s[::-1]:
        result += translation[c] * (5**place)
        place += 1
    return result


def encode(n):
    translation = {
        -2: "=",
        -1: "-",
        0: "0",
        1: "1",
        2: "2",
        3: "=",
        4: "-",
    }
    result = ""
    while n > 0:
        digit = n % 5
        if digit > 2:
            n += 5
        result += translation[digit]
        n = n // 5
    return result[::-1].lstrip("0")


decoded = map(decode, lines)
s = sum(decoded)

# part 1
print(encode(s))

