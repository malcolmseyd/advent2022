import itertools as it
import functools as ft
from collections import defaultdict, Counter
import re

with open("input12.txt") as f:
    input_full = f.read()

input = [line for line in input_full.strip().split()]

inf = 10000000

coords = {(x, y) for y in range(len(input)) for x in range(len(input[0]))}


heights = {(x, y): ord(input[y][x]) for (x, y) in coords}

start = [v for v in coords if heights[v] == ord("S")][0]
heights[start] = ord('a')
end = [v for v in coords if heights[v] == ord("E")][0]
heights[end] = ord('z')

# for part 2, we swap the and start. the "end" is the single source so we can query all a's
start, end = end, start

dist = {k: inf for k in coords}
dist[start] = 0

prev = {k: None for k in coords}

unvisited = {(x, y) for y in range(len(input))
             for x in range(len(input[0]))}


def neigh(src: tuple[int, int]):
    def movable(dst):
        if dst not in coords:
            return False
        # swap for part 2
        # return heights[dst] - heights[src] <= 1
        return heights[src] - heights[dst] <= 1

    x, y = src
    near = [(x, y - 1), (x, y + 1), (x - 1, y), (x + 1, y)]
    return [v for v in near if movable(v)]


while len(unvisited) != 0:
    v = min(unvisited, key=lambda k: dist[k])
    # print(v)
    # print(dist)
    unvisited.remove(v)

    # print(neigh(v))
    for n in neigh(v):
        new_dist = dist[v] + 1
        # print(f"new dist={new_dist}")
        if new_dist < dist[n]:
            dist[n] = new_dist
            prev[n] = v


# part 1
print(dist[end])
# part 2
print(min( [dist[v] for v in dist if heights[v] == ord('a')] ))
