#!/usr/bin/env python3

import csv
import os
import statistics
import sys
from math import sqrt


def sem(data):
    return statistics.stdev(data) / sqrt(len(data))

def schedules_run(in_dir):
    name = os.path.basename(in_dir).split('-')[1]
    pradet, pfast = [], []

    with open(os.path.join(in_dir, "stats-pradet.csv")) as fp:
        fp.readline()

        pradet = list(map(lambda x: int(x.strip().split(',')[1]), fp.readlines()))

    with open(os.path.join(in_dir, "stats-pfast.csv")) as fp:
        fp.readline()

        pfast = list(map(lambda x: int(x.strip().split(',')[1]), fp.readlines()))

    return [
        name,
        statistics.mean(pradet) - sem(pradet),
        statistics.mean(pradet),
        statistics.mean(pradet) + sem(pradet),
        statistics.mean(pfast) - sem(pfast),
        statistics.mean(pfast),
        statistics.mean(pfast) + sem(pfast),
    ]


def running_time(in_dir):
    name = os.path.basename(in_dir).split('-')[1]
    pradet, pfast = [], []

    with open(os.path.join(in_dir, "stats-pradet.csv")) as fp:
        fp.readline()

        pradet = list(map(lambda x: float(x.strip().split(',')[3]), fp.readlines()))

    with open(os.path.join(in_dir, "stats-pfast.csv")) as fp:
        fp.readline()

        pfast = list(map(lambda x: float(x.strip().split(',')[3]), fp.readlines()))

    return [
        name,
        statistics.mean(pradet) - sem(pradet),
        statistics.mean(pradet),
        statistics.mean(pradet) + sem(pradet),
        statistics.mean(pfast) - sem(pfast),
        statistics.mean(pfast),
        statistics.mean(pfast) + sem(pfast),
    ]

def main(path, out_dir):
    data = {
        'schedules-run': [],
        'running-time': [],
    }

    dirs = []

    for f in os.listdir(path):
        if not os.path.isdir(os.path.join(path, f)) or not f.startswith('testsuite-'):
            continue
        dirs.append(os.path.join(path, f))
    dirs.sort()

    for d in dirs:
        data['schedules-run'].append(schedules_run(d))
        data['running-time'].append(running_time(d))

    for key in data:
        with open(os.path.join(out_dir, f"{key}.dat"), "w") as fp:
            for line in data[key]:
                print(" ".join(map(str, line)), file=fp)


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} [path to directory] [out dir]", file=sys.stderr)
        exit(1)
    main(sys.argv[1], sys.argv[2])
