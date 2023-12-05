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
      -i "$graph" -t java-selenium -d ./selenium-driver.yaml \
      "testsuites/$testsuite" >> "$EXPERIMENT_LOGS" 2>&1
    if [ "$?" -eq  0 ]; then
      return 0
    fi
  done

  return 1
}

single_iteration() {
  local testsuite="$1"
  local strategy="$2"
  local runners="12"

  local TIME="$(date  +"%d-%m-%y-%H-%M-%S")"
  local LOG_FILE="results/$testsuite/log-$strategy-$TIME.json"
  local GRAPH_FILE="results/$testsuite/graph-$strategy-$TIME.json"
  local SCHEDULES_FILE="results/$testsuite/schedules-$strategy-$TIME.json"

  "$GTDD_EXEC" deps --log debug --format json --log-file "$LOG_FILE" \
    -v app_url=http://app \
    -v driver_url=http://selenium:4444 \
    -o "$GRAPH_FILE" -t java-selenium -r "$runners" -s "$strategy" \
    -d ./selenium-driver.yaml \
    "testsuites/$testsuite" >> "$EXPERIMENT_LOGS" 2>&1
  if [ "$?" -ne  0 ]; then
    return
  fi

  "$GTDD_EXEC" schedules -t java-selenium  -i "$GRAPH_FILE" \
    -o "$SCHEDULES_FILE" \
    "testsuites/$testsuite"

  if ! run_testsuite "$testsuite" "$(nproc --all)" "$GRAPH_FILE"; then
    echo "Schedule $SCHEDULES_FILE does not work" >> "$EXPERIMENT_LOGS"
  fi

  ./compute-stats.py "$LOG_FILE" \
    "$SCHEDULES_FILE" \
    "results/$testsuite/stats-$strategy.csv"  >> "$EXPERIMENT_LOGS" 2>&1
}

run_experiment() {
  local testsuite="$1"

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
    single_iteration "$testsuite" 'pradet'
    single_iteration "$testsuite" 'pfast'
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
  if [ -d "./results/$testsuite" ]; then
    continue
  fi
  run_experiment "$testsuite"
done
