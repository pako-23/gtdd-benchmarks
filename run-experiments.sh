#!/bin/sh

set -u

CURR_DIR="$PWD"
EXPERIMENT_LOGS="./results/logs.log"

run_testsuite() {
  local testsuite="$1"
  local runners="$2"
  local graph="$3"

  for i in $(seq 1 3); do
    "$GTDD_EXEC" run -v app_url=http://app \
      -v driver_url=http://selenium:4444 -r "$runners" \
      -i "$graph" -d ./driver.yaml \
      "testsuites/$testsuite" >> "$EXPERIMENT_LOGS" 2>&1
    if [ "$?" -eq  0 ]; then
      return 0
    fi
  done

  return 1
}

run_experiment() {
  local testsuite="$1"
  local strategy="$2"
  local runners="12"

  if ! "$GTDD_EXEC" build "testsuites/$testsuite" >> "$EXPERIMENT_LOGS" 2>&1; then
    return
  fi

  if ! run_testsuite "$testsuite" '1' ''; then
    return
  fi

  if ! [ -d "results/$testsuite" ]; then
    mkdir -p "results/$testsuite"
  fi

  for i in $(seq 1 10); do
    TIME="$(date  +"%d-%m-%y-%H-%M-%S")"
    LOG_FILE="results/$testsuite/log-$strategy-$TIME.json"
    GRAPH_FILE="results/$testsuite/graph-$strategy-$TIME.json"
    SCHEDULES_FILE="results/$testsuite/schedules-$strategy-$TIME.json"

    "$GTDD_EXEC" deps --log debug --format json --log-file "$LOG_FILE" \
      -v app_url=http://app \
      -v driver_url=http://selenium:4444 \
      -o "$GRAPH_FILE" -r "$runners" -s "$strategy" \
      -d ./driver.yaml \
      "testsuites/$testsuite" >> "$EXPERIMENT_LOGS" 2>&1
    if [ "$?" -ne  0 ]; then
      continue
    fi

    "$GTDD_EXEC" schedules -i "$GRAPH_FILE" \
      -o "$SCHEDULES_FILE" \
      "testsuites/$testsuite"

    if ! run_testsuite "$testsuite" "$(nproc --all)" "$GRAPH_FILE"; then
      echo "Schedule $SCHEDULES_FILE does not work" >> "$EXPERIMENT_LOGS"
    fi

    ./compute-stats.py "$LOG_FILE" \
      "$SCHEDULES_FILE" \
      "results/$testsuite/stats-$strategy.csv"  >> "$EXPERIMENT_LOGS" 2>&1
  done
}




# TODO: refactor this part
cd ../gtdd
make
GTDD_EXEC="../gtdd/gtdd"
cd "$CURR_DIR"
#######

if ! [ -d results ]; then
  mkdir -p results
fi

for testsuite in $(ls ./testsuites); do
  if [ -f "./results/$testsuite/stats-$1.csv" ]; then
    continue
  fi
  run_experiment "$testsuite" "$1"
done
