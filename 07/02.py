import functools
import operator
import re
from collections import Counter


def agg_value(tree):
    agg = list(tree.keys())[0][1]
    for c in list(tree.values())[0]:
        agg += agg_value(c)
    return agg


def find_unbalanced_tower(t, return_diff=False):
    children = list(t.values())
    assert len(children) == 1
    children = children[0]

    agg_vals = [
        z for z in zip(
            [list(x.keys())[0] for x in children],
            [agg_value(c) for c in children]
        )
    ]
    counter = Counter()
    for av in agg_vals:
        counter[av[1]] += 1
    assert len(counter) == 2

    unbalanced_agg = [x for x in counter.items() if x[1] == 1]
    assert len(unbalanced_agg) == 1

    bad_node = [x for x in agg_vals if x[1] == unbalanced_agg[0][0]]
    assert len(bad_node) == 1

    if return_diff:
        return functools.reduce(
            operator.sub,
            reversed([x[0] for x in counter.items()])
        )
    return [x for x in children if list(x.keys())[0][0] == bad_node[0][0][0]][0]


def build_tree(node, progs):
    return {
        (node, progs[node][0]): [build_tree(x, progs) for x in progs[node][1]]
    }


def walk_until_balanced(t):
    try:
        u = find_unbalanced_tower(t)
    except AssertionError:
        return t.keys()
    return walk_until_balanced(u)


def main():
    with open('input.txt', 'r') as o:
        raw_progs = [x.split('->') for x in o.read().strip().split("\n")]

    progs = {}
    for p in raw_progs:
        (prog, weight) = re.compile(r"^(.*?)\s+\((.*?)\)").findall(p[0])[0]
        weight = int(weight)
        children = [x.strip() for x in p[1].split(",")] if len(p) > 1 else []
        progs[prog] = (weight, children)

    tree = build_tree("vvsvez", progs)
    weight_diff = find_unbalanced_tower(tree, return_diff=True)
    last_unbalanced = walk_until_balanced(tree)
    return list(last_unbalanced)[0][1] - weight_diff


if __name__ == '__main__':
    expected = 362
    assert main() == expected
