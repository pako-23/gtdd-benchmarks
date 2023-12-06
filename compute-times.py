#!/usr/bin/env python3

import csv
import json
import sys
import os
import glob


def splitting(s, key):
    if len(s.split(key)) == 1:
        return '0', s
    else:
        return s.split(key)

def time_to_seconds(s):
    seconds = 0
    hours, rest = splitting(s, "h")
    seconds += 3600*int(hours)
    minutes, rest = splitting(s, "m")
    seconds += 60*int(minutes)
    return seconds + float(rest[:-1])

def get_running_time(file):
    with open(file, "r") as fp:
        for line in fp:
            data = json.loads(line)
            if data["msg"].startswith("expected running time "):
                return time_to_seconds(data["msg"].split()[-1])

def get_algo(file):
    if "sequential" in file:
        return "sequential"
    elif "pfast" in file:
        return "pfast"
    else:
        return "pradet"
def main(base, outfile):
    data = {
        "sequential": [],
        "pfast": [],
        "pradet": []
    }

    for file in glob.glob(os.path.join(base, "*.json")):
        data[get_algo(file)].append(get_running_time(file))

    with open(outfile, "w") as fp:
        out = csv.writer(fp)
        out.writerow([
            "sequential",
            "pfast",
            "pradet",
        ])

        for i in range(len(data["pfast"])):
            out.writerow([
                data["sequential"][i],
                data["pfast"][i],
                data["pradet"][i],
            ])

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} [logs dir] [output csv file]", file=sys.stderr)
        exit(1)
    main(sys.argv[1], sys.argv[2])
