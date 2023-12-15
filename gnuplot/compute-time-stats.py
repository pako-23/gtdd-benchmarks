#!/usr/bin/env python3

import csv
import os
import statistics
import sys
from math import sqrt


def sem(data):
    return statistics.stdev(data) / sqrt(len(data))

def max_execution(in_dir):
    name = os.path.basename(in_dir).split('-')[1]
    seq, pradet, pfast = [], [], []

    with open(os.path.join(in_dir, "stats.csv")) as fp:
        fp.readline()

        data = map(lambda x: list(map(float, x.strip().split(',')[0:3])), fp.readlines())

    for line in data:
        seq.append(line[0])
        pradet.append(line[1])
        pfast.append(line[2])

    return [
        name,
        statistics.mean(seq) - sem(seq),
        statistics.mean(seq),
        statistics.mean(seq) + sem(seq),
        statistics.mean(pradet) - sem(pradet),
        statistics.mean(pradet),
        statistics.mean(pradet) + sem(pradet),
        statistics.mean(pfast) - sem(pfast),
        statistics.mean(pfast),
        statistics.mean(pfast) + sem(pfast),
    ]

def tot_work(in_dir):
    name = os.path.basename(in_dir).split('-')[1]
    seq, pradet, pfast = [], [], []

    with open(os.path.join(in_dir, "stats.csv")) as fp:
        fp.readline()
        data = map(lambda x: list(map(float, x.strip().split(',')[3:6])), fp.readlines())

    for line in data:
        seq.append(line[0])
        pradet.append(line[1])
        pfast.append(line[2])

    return [
        name,
        statistics.mean(seq) - sem(seq),
        statistics.mean(seq),
        statistics.mean(seq) + sem(seq),
        statistics.mean(pradet) - sem(pradet),
        statistics.mean(pradet),
        statistics.mean(pradet) + sem(pradet),
        statistics.mean(pfast) - sem(pfast),
        statistics.mean(pfast),
        statistics.mean(pfast) + sem(pfast),
    ]


def cpu_number(in_dir):
    name = os.path.basename(in_dir).split('-')[1]
    seq, pradet, pfast = [], [], []

    with open(os.path.join(in_dir, "stats.csv")) as fp:
        fp.readline()
        data = map(lambda x: list(map(int, x.strip().split(',')[6:9])), fp.readlines())

    for line in data:
        seq.append(line[0])
        pradet.append(line[1])
        pfast.append(line[2])

    return [
        name,
        statistics.mean(seq) - sem(seq),
        statistics.mean(seq),
        statistics.mean(seq) + sem(seq),
        statistics.mean(pradet) - sem(pradet),
        statistics.mean(pradet),
        statistics.mean(pradet) + sem(pradet),
        statistics.mean(pfast) - sem(pfast),
        statistics.mean(pfast),
        statistics.mean(pfast) + sem(pfast),
    ]


def main(path, out_dir):
    data = {
        'max-execution': [],
        'tot-work': [],
        'cpu-number': [],
    }

    dirs = []

    for f in os.listdir(path):
        if not os.path.isdir(os.path.join(path, f)) or not f.startswith('testsuite-'):
            continue
        dirs.append(os.path.join(path, f))

    dirs.sort()
    for d in dirs:
        data['max-execution'].append(max_execution(d))
        data['tot-work'].append(tot_work(d))
        data['cpu-number'].append(cpu_number(d))

    for key in data:
        with open(os.path.join(out_dir, f"{key}.dat"), "w") as fp:
            for line in data[key]:
                print(" ".join(map(str, line)), file=fp)


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} [path to directory] [out dir]", file=sys.stderr)
        exit(1)
    main(sys.argv[1], sys.argv[2])
