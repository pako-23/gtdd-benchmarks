#!/usr/bin/env python3


import json
import sys


def fix_test_name(name):
    return "#".join(name.strip().rsplit(".", 1))


def main(order, deps):
    with open(order, "r") as fp:
        graph = dict(map(lambda x: (fix_test_name(x), []), fp.readlines()))

    with open(deps, "r") as fp:
        for line in fp.readlines():
            if len(line.strip()) == 0:
                continue
            print(f"line: {line}")
            u, v = line.strip().split(",")
            if u == v:
                continue

            graph[fix_test_name(u)].append(fix_test_name(v))

    return graph


if __name__ == "__main__":
    if len(sys.argv) != 4:
        print(
            f"Usage: {sys.argv[0]} [run-order path] [deps path] [output file]",
            file=sys.stderr,
        )
        exit(1)
    graph = main(sys.argv[1], sys.argv[2])

    with open(sys.argv[3], "w") as fp:
        json.dump(graph, fp)
