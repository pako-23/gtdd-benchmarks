#!/usr/bin/env python3

import csv
import json
import os
import sys


def compute_log_stats(logs):
    test_suite_runs = 0
    tests_runned = 0
    fp = open(logs, "r")

    for line in fp:
        data = json.loads(line)
        if data["msg"].startswith("run tests "):
            test_results = data["msg"][data["msg"].find("]") + 1 :]
            suite_begin = test_results.find("[")
            suite_end = test_results.find("]")

            test_results = test_results[suite_begin + 1 : suite_end].split()

            try:
                tests_runned += test_results.index("false") + 1
            except:
                tests_runned += len(test_results)

            test_suite_runs += 1

    fp.close()

    return test_suite_runs, tests_runned


def compute_graph_stats(filename):
    with open(filename, "r") as fp:
        schedules = json.load(fp)

    tests = set()
    for schedule in schedules:
        tests = tests.union(schedule)

    return len(tests), max(map(len, schedules)), sum(map(len, schedules))


def main(logs, graph, outfile, time):
    add_header = not os.path.isfile(outfile)

    with open(outfile, "a") as fp:
        out = csv.writer(fp)
        if add_header:
            out.writerow(
                [
                    "n",
                    "test_suite_runs",
                    "tests_runned",
                    "time",
                    "longest_cost",
                    "tot_cost",
                ]
            )

        if not os.path.isfile(graph):
            out.writerow(["-"] * 6)
        else:
            test_suite_runs, tests_runned = compute_log_stats(logs)
            n, longest_cost, tot_cost = compute_graph_stats(graph)

            out.writerow(
                [
                    n,
                    test_suite_runs,
                    tests_runned,
                    time,
                    longest_cost,
                    tot_cost,
                ]
            )


if __name__ == "__main__":
    if len(sys.argv) != 5:
        print(
            f"Usage: {sys.argv[0]} [path to json logs] [path to schedules] [output csv file] [running time]",
            file=sys.stderr,
        )
        exit(1)
    main(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])
