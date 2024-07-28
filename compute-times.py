#!/usr/bin/env python3

import csv
import json
import sys
import os
import glob


def splitting(s, key):
    if len(s.split(key)) == 1:
        return "0", s
    else:
        return s.split(key)


def time_to_seconds(s):
    seconds = 0
    hours, rest = splitting(s, "h")
    seconds += 3600 * int(hours)
    minutes, rest = splitting(s, "m")
    seconds += 60 * int(minutes)
    return seconds + float(rest[:-1])


def get_running_time(file):
    tot_work = 0
    max_execution = 0
    cpu_number = 0

    with open(file, "r") as fp:
        for line in fp:
            data = json.loads(line)
            if data["msg"].startswith("expected running time "):
                max_execution = time_to_seconds(data["msg"].split()[-1])
            elif data["msg"].startswith("run schedule in"):
                cpu_number += 1
                tot_work += time_to_seconds(data["msg"].split()[-1])

    return max_execution, tot_work, cpu_number


def get_algo(file):
    if "sequential" in file:
        return "sequential"
    elif "pfast" in file:
        return "pfast"
    elif "pradet" in file:
        return "pradet"
    else:
        return "mem_fast"


def main(base, outfile):
    keys = [
        "sequential_max_execution",
        "pradet_max_execution",
        "pfast_max_execution",
        "mem_fast_execution",
        "sequential_tot_work",
        "pradet_tot_work",
        "pfast_tot_work",
        "mem_fast_tot_work",
        "sequential_cpu_number",
        "pfast_cpu_number",
        "pradet_cpu_number",
        "mem_fast_cpu_number",
    ]
    data = dict(((key, []) for key in keys))

    for file in glob.glob(os.path.join(base, "*.json")):
        algo = get_algo(file)
        max_execution, tot_work, cpu_number = get_running_time(file)
        data[f"{algo}_max_execution"].append(max_execution)
        data[f"{algo}_tot_work"].append(tot_work)
        data[f"{algo}_cpu_number"].append(cpu_number)

    with open(outfile, "w") as fp:
        out = csv.writer(fp)
        out.writerow(keys)

        for i in range(len(data["sequential_max_execution"])):
            out.writerow([data[key][i] for key in keys])


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} [logs dir] [output csv file]", file=sys.stderr)
        exit(1)
    main(sys.argv[1], sys.argv[2])
