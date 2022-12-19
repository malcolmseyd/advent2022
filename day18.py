import itertools as it
import functools as ft
from collections import defaultdict, Counter
import re

with open("input18.txt") as f:
    input_all = f.read()

# input_all = """
# 2,2,2
# 1,2,2
# 3,2,2
# 2,1,2
# 2,3,2
# 2,2,1
# 2,2,3
# 2,2,4
# 2,2,6
# 1,2,5
# 3,2,5
# 2,1,5
# 2,3,5
# """

input = {tuple([int(coords) for coords in line.split(",")])
         for line in input_all.strip().split()}

# part 1

faces = 0


def neigh(coord):
    x, y, z = coord
    return [
        (x+1, y, z),
        (x-1, y, z),
        (x, y+1, z),
        (x, y-1, z),
        (x, y, z+1),
        (x, y, z-1),
    ]


for x, y, z in input:
    for pos in neigh((x, y, z)):
        if pos not in input:
            faces += 1

print(faces)

# part 2

# game plan:
# - group lava by touching pieces
# - find outside air for each group
# - count number of faces touching outside air

# group lava into touching pieces


def neigh_corners(coord):
    x, y, z = coord
    xs = [x, x+1, x-1]
    ys = [y, y+1, y-1]
    zs = [z, z+1, z-1]
    return set(it.product(xs, ys, zs)) - {(x, y, z)}


# we'll use a disjoint set
parents = defaultdict(lambda: None)


def find_djs(coord):
    parent = parents[coord]
    if parent is None:
        # coord is already root
        return coord
    root = coord
    while parent is not None:
        root = parent
        parent = parents[parent]
    # update parent for faster lookup
    parents[coord] = root
    return root


def union_djs(c1, c2):
    # add c2 to c1's group
    r1 = find_djs(c1)
    r2 = find_djs(c2)
    if r1 != r2:
        parents[r2] = r1


# populate set
for coord in input:
    for n in neigh_corners(coord):
        # if n isn't touching another cube, keep looking
        if n not in input:
            continue
        # add node to our set
        union_djs(coord, n)

# now that we have parent dict, actually make groups
groups = defaultdict(set)
for coord, parent in parents.items():
    root = find_djs(coord)
    groups[root].add(coord)
groups = groups.values()


def touching_group(c, g):
    # is c is touching a chunk in g?
    for n in neigh_corners(c):
        if n in g:
            return True
    return False


outside_faces = 0

# search each set for air bubbles
for g in groups:

    # works since position tuple is (x,y,z)
    # cube with highest x is guaranteed to be on the outside
    highest_x_lava = max(g)
    hx, hy, hz = highest_x_lava

    # x+1 is guaranteed to be outside air
    highest_x_air = (hx+1, hy, hz)

    # do 3d BFS
    unexplored_air = [highest_x_air]
    outside_air = {highest_x_air}

    # discover all squares of air that are connected to that outside air
    # gameplan:
    # - make set of outside air
    # - keep visiting neighbours that are touching lava
    # - count faces that touch the outside air

    outside_air = set()
    old_size = -1
    while len(unexplored_air) != 0:
        curr = unexplored_air.pop(0)
        for n in neigh(curr):
            # new squares of air that are touching g
            if n not in outside_air and n not in g and touching_group(n, g):
                outside_air.add(n)
                unexplored_air.append(n)

    for c in g:
        for n in neigh(c):
            if n in outside_air:
                outside_faces += 1


print(outside_faces)
