#!/bin/sh

set -u

RUNNERS=4

# TODO: refactor this part
CURR_DIR="$PWD"

cd ../gtdd
make

GTDD_EXEC="../gtdd/gtdd"

cd "$CURR_DIR"
#######






mkdir -p results

for testsuite in $(ls testsuites | grep ppma); do
  if ! "$GTDD_EXEC" build "testsuites/$testsuite"; then
    continue
  fi

  "$GTDD_EXEC" run -v app_url=http://app \
    -v driver_url=http://selenium:4444 -r 1 \
    -d selenium=selenium/standalone-chrome:115.0 \
    "testsuites/$testsuite"
  if [ "$?" -ne  0 ]; then
    continue
  fi

  mkdir -p "results/$testsuite"
  TIME="$(date  +"%d-%m-%y-%H-%M-%S")"
  LOG_FILE="results/$testsuite/log-$TIME.json"
  GRAPH_FILE="results/$testsuite/graph-$TIME.json"
  SCHEDULES_FILE="results/$testsuite/schedules-$TIME.json"

  "$GTDD_EXEC" deps --log debug --format json --log-file "$LOG_FILE" \
    -v app_url=http://app \
    -v driver_url=http://selenium:4444 \
    -o "$GRAPH_FILE" -r "$RUNNERS" -s ex-linear \
    -d selenium=selenium/standalone-chrome:115.0 \
    "testsuites/$testsuite"
  if [ "$?" -ne  0 ]; then
    continue
  fi

  "$GTDD_EXEC" run -v app_url=http://app \
    -v driver_url=http://selenium:4444 \
    -i "$GRAPH_FILE" -r "$RUNNERS" \
    -d selenium=selenium/standalone-chrome:115.0 \
    "testsuites/$testsuite"
  if [ "$?" -ne  0 ]; then
    continue
  fi


  "$GTDD_EXEC" schedules -i "$GRAPH_FILE" \
    -o "$SCHEDULES_FILE" \
    "testsuites/$testsuite"

  ./compute-stats.py "$LOG_FILE" "$SCHEDULES_FILE" "results/$testsuite/stats.csv"
done
