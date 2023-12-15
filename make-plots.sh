#!/bin/sh -eu

mkdir -p plots
./gnuplot/compute-running-stats.py ./results/ ./plots/
./gnuplot/compute-time-stats.py ./results/timing/ ./plots/

for i in ./gnuplot/*.gp; do
  gnuplot "$i"
done
