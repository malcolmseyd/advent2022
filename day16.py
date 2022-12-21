import itertools as it
import functools as ft
from collections import defaultdict, Counter, deque
import re

with open("input16.txt") as f:
    input_full = f.read()

example1 = """Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
Valve BB has flow rate=13; tunnels lead to valves CC, AA
Valve CC has flow rate=2; tunnels lead to valves DD, BB
Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
Valve EE has flow rate=3; tunnels lead to valves FF, DD
Valve FF has flow rate=0; tunnels lead to valves EE, GG
Valve GG has flow rate=0; tunnels lead to valves FF, HH
Valve HH has flow rate=22; tunnel leads to valve GG
Valve II has flow rate=0; tunnels lead to valves AA, JJ
Valve JJ has flow rate=21; tunnel leads to valve II"""

# input_full = example1

pat = re.compile(
    "^Valve (.*) has flow rate=(.*); tunnels? leads? to valves? (.*)$")


def parse(line):
    m = pat.match(line)
    from_v, flow_rate, to_v = m.groups()
    return from_v, int(flow_rate), to_v.split(", ")


flows = [parse(line) for line in input_full.strip().split("\n")]

# this smells like a graph
tunnels = {from_v: to_v for from_v, _, to_v in flows}
rate = {from_v: rate for from_v, rate, _ in flows}

# do BFS from each node to generate unweighted all-pairs shortest paths
dist = defaultdict(dict)
for source in tunnels:
    # self is zero away
    dist[source][source] = 0

    # bfs
    next = deque([source])
    while len(dist[source]) != len(flows):
        curr = next.popleft()
        for t in tunnels[curr]:
            if t not in dist[source]:
                dist[source][t] = dist[source][curr]+1
                next.append(t)

unopened = frozenset({valve for valve, rate in rate.items() if rate != 0})


@ft.cache
def find_max_flow(source, unopened, time):
    # base case
    max_flow = 0

    # calculate the max possible flow for each path
    for valve in unopened:
        # travel time + 1 for opening
        wait_time = dist[source][valve] + 1
        time_after = time - wait_time
        if time_after <= 0:
            # skip redundant
            continue

        # calculate total flow
        flow = time_after * rate[valve]
        next_unopened = unopened - {valve}
        total_flow = flow + find_max_flow(valve, next_unopened, time_after)

        # maybe update max flow
        max_flow = max(max_flow, total_flow)

    return max_flow


# part 1
print(find_max_flow("AA", unopened, 30))

max_both_flow = 0
for k in range(len(unopened)+1):
    for my_unopened in map(frozenset, it.combinations(unopened, k)):
        my_flow = find_max_flow("AA", my_unopened, 26)

        elephant_unopened = unopened - my_unopened
        elephant_flow = find_max_flow("AA", elephant_unopened, 26)

        max_both_flow = max(max_both_flow, my_flow + elephant_flow)

# part 2
print(max_both_flow)

print("done.")
