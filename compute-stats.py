#!/usr/bin/env python3

import csv
import json
import os
import sys
from datetime import datetime


def compute_log_stats(logs):
    test_suite_runs = 0
    tests_runned = 0
    fp = open(logs, 'r')

    for line in fp:
        data = json.loads(line)
        if data["msg"] == "starting dependency detection algorithm":
            begin = datetime.strptime(data["time"], '%Y-%m-%dT%H:%M:%SZ')
        elif data["msg"].startswith("run tests "):
            suite_begin = data["msg"].find('[')
            suite_end = data["msg"].find(']')
            tests_runned += len(data["msg"][suite_begin:suite_end+1].split())
            test_suite_runs += 1
        elif data["msg"] == "finished dependency detection algorithm":
            end = datetime.strptime(data["time"], '%Y-%m-%dT%H:%M:%SZ')

    fp.close()

    return end-begin, test_suite_runs, tests_runned


def compute_graph_stats(filename):
    with open(filename, 'r') as fp:
        schedules = json.load(fp)

    tests = set()
    for schedule in schedules:
        tests = tests.union(schedule)

    return len(tests), max(map(len, schedules)), sum(map(len, schedules))


def main(logs, graph, outfile):
    time, test_suite_runs, tests_runned = compute_log_stats(logs)
    n, longest_cost, tot_cost = compute_graph_stats(graph)

    add_header = not os.path.isfile(outfile)

    with open(outfile, 'a') as fp:
        out = csv.writer(fp)
        if add_header:
            out.writerow([
                "n",
                "test_suite_runs",
                "tests_runned",
                "time",
                "longest_cost",
                "tot_cost",
            ])

        out.writerow([
            n,
            test_suite_runs,
            tests_runned,
            time.total_seconds(),
            longest_cost,
            tot_cost,
        ])

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print(f"Usage: {sys.argv[0]} [path to json logs] [path to schedules] [output csv file]", file=sys.stderr)
        exit(1)
    main(sys.argv[1], sys.argv[2], sys.argv[3])
