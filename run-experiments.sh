#!/bin/sh

set -u

RUNNERS=4
CURR_DIR="$PWD"
EXPERIMENT_LOGS="./results/logs.log"

run_testsuite() {
  local testsuite="$1"
  local runners="$2"
  local graph="$3"

  for i in $(seq 1 3); do
    "$GTDD_EXEC" run -v app_url=http://app \
      -v driver_url=http://selenium:4444 -r "$runners" \
      -i "$graph" -d selenium=selenium/standalone-chrome:115.0 \
      "testsuites/$testsuite" >> "$EXPERIMENT_LOGS" 2>&1
    if [ "$?" -eq  0 ]; then
      return 0
    fi
  done

  return 1
}

run_experiment() {
  local testsuite="$1"

  if ! "$GTDD_EXEC" build "testsuites/$testsuite" >> "$EXPERIMENT_LOGS" 2>&1; then
    return
  fi

  if ! run_testsuite "$testsuite" '1' ''; then
    return
  fi

  mkdir -p "results/$testsuite"

  for i in $(seq 1 10); do
    TIME="$(date  +"%d-%m-%y-%H-%M-%S")"
    LOG_FILE="results/$testsuite/log-$TIME.json"
    GRAPH_FILE="results/$testsuite/graph-$TIME.json"
    SCHEDULES_FILE="results/$testsuite/schedules-$TIME.json"

    "$GTDD_EXEC" deps --log debug --format json --log-file "$LOG_FILE" \
      -v app_url=http://app \
      -v driver_url=http://selenium:4444 \
      -o "$GRAPH_FILE" -r "$RUNNERS" -s pfast \
      -d selenium=selenium/standalone-chrome:115.0 \
      "testsuites/$testsuite" >> "$EXPERIMENT_LOGS" 2>&1
    if [ "$?" -ne  0 ]; then
      continue
    fi

    "$GTDD_EXEC" schedules -i "$GRAPH_FILE" \
      -o "$SCHEDULES_FILE" \
      "testsuites/$testsuite"

    ./compute-stats.py "$LOG_FILE" "$SCHEDULES_FILE" "results/$testsuite/stats.csv"
  done
}




# TODO: refactor this part
cd ../gtdd
make

GTDD_EXEC="../gtdd/gtdd"
cd "$CURR_DIR"
#######

mkdir -p results

for testsuite in $(ls testsuites); do
  run_experiment "$testsuite"
done
