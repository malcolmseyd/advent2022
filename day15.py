import itertools as it
import functools as ft
from collections import defaultdict, Counter, deque
import re
import math

sensors = []
for line in open(0):
    sx, sy, bx, by = map(int, re.findall(r"-?\d+", line))
    sensors.append(((sx, sy), (bx, by)))

# print(sensors)


def distance(a, b):
    ax, ay = a
    bx, by = b
    return abs(ax - bx) + abs(ay - by)


# part 1
min_x, min_y = math.inf, math.inf
max_x, max_y = -math.inf, -math.inf
for sensor, beacon in sensors:
    r = distance(sensor, beacon)
    sx, sy = sensor
    min_x = min(min_x, sx - r)
    min_y = min(min_y, sy - r)
    max_x = max(max_x, sx + r)
    max_y = max(max_y, sy + r)
    # print(sensor, r)
# print((min_x, min_y), (max_x), (max_y))

def not_beacon(coord):
    for sensor, beacon in sensors:
        # beacons are beacons
        if coord == beacon:
            return False
        r = distance(sensor, beacon)
        d = distance(sensor, coord)
        # inside radius and not on beacon means can't be another beacon
        if d <= r:
            # print(f"{sensor=} {beacon=} {r=} {d=}")
            return True
    # outside of every sensor's radius
    return False

# PART1_Y = 10
PART1_Y = 2000000
not_beacon_positions = 0
for x in range(min_x, max_x + 1):
    # if x % 100000 == 0:
    #     print(f"{(x-min_x)/(max_x-min_x)*100:.4}% done")
    coord = (x, PART1_Y)
    if not_beacon(coord):
        not_beacon_positions += 1

print(not_beacon_positions)

# part 2

# there is only ONE answer, so this narrows down the search a lot

# in the example, the unique solution was found one outside of a sensor's range
# we can search the outline of each sensor for a solution

def undiscovered_beacon(coord):
    for sensor, beacon in sensors:
        r = distance(sensor, beacon)
        d = distance(sensor, coord)
        # inside radius means can't be another beacon
        if d <= r:
            return False
    # outside of every sensor's radius
    # print(f"{sensor=} {beacon=} {r=} {d=}")
    return True

# P2_MAX = 20
P2_MAX = 4000000

# searched = 0
for sensor, beacon in sensors:
    # print(f"{searched/len(sensors)*100:.4}%")
    # searched+=1
    r = distance(sensor, beacon)
    out = r+1
    sx, sy = sensor
    # print(f"{sensor=} {beacon=} {r=} {out=}")

    left = sx - out, sy
    right = sx + out, sy
    top = sx, sy - out
    bottom = sx, sy + out

    x, y = left
    delta = (1, -1)  # right, up 
    # start at the left and rotate clockwise around the radius
    # stop when we reach the left again
    while True:
        dx, dy = delta
        x += dx
        y += dy
        # print(x,y)

        if 0 <= x <= P2_MAX and 0 <= y <= P2_MAX and undiscovered_beacon((x, y)):
            # print("FOUND")
            # print(x, y)
            print(x * 4000000 + y)
            exit(0)

        if (x, y) == left:
            # print("left")
            break # finished a full rotation
        elif (x, y) == top:
            # print("top")
            delta = (1, 1)  # right, down
        elif (x, y) == right:
            # print("right")
            delta = (-1, 1) # left, down
        elif (x, y) == bottom:
            # print("bottom")
            delta = (-1, -1) # left, up
