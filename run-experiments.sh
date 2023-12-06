#!/bin/sh

set -u

CURR_DIR="$PWD"
EXPERIMENT_LOGS="./results/logs.log"

run_testsuite() {
  local testsuite="$1"
  local graph="$2"
  local out_file="$3"
  local runners="$(expr "$(nproc --all)" \* 3 / 4)"

  for i in $(seq 1 3); do
    "$GTDD_EXEC" run --format json --log-file "$out_file" \
      -v app_url=http://app \
      -v driver_url=http://selenium:4444 -r "$runners" \
      -i "$graph" -t java-selenium -d ./selenium-driver.yaml \
      "testsuites/$testsuite"
    if [ "$?" -eq  0 ]; then
      return 0
    fi
  done

  echo "Schedule $graph does not work" >> "$EXPERIMENT_LOGS"
  return 1
}

single_iteration() {
  local testsuite="$1"
  local strategy="$2"
  local runners="$(expr "$(nproc --all)" \* 3 / 4)"

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

  ./compute-stats.py "$LOG_FILE" \
    "$SCHEDULES_FILE" \
    "results/$testsuite/stats-$strategy.csv"  >> "$EXPERIMENT_LOGS" 2>&1
}

run_experiment() {
  local testsuite="$1"

  if ! "$GTDD_EXEC" build -t java-selenium "testsuites/$testsuite" >> "$EXPERIMENT_LOGS" 2>&1; then
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

test_schedules() {
  local testsuite="$1"
  local runners="$(expr "$(nproc --all)" \* 3 / 4)"

  if ! [ -d "./results/timing/$testsuite" ]; then
    mkdir -p "./results/timing/$testsuite"
  fi

  for i in $(seq 1 10); do
    run_testsuite "$testsuite" '' "./results/timing/$testsuite/sequential-$i.json"
  done

  for schedule in "./results/$testsuite/schedules-"*; do

    graph="$(echo "$schedule" | sed s/schedules-/graph-/)"

    run_testsuite "$testsuite" "$graph" "./results/timing/$testsuite/$(basename "$graph")"
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

if ! [ -d results/timing ]; then
  mkdir -p results/timing
fi

for testsuite in $(ls ./testsuites); do
  if [ -f "./results/timing/$testsuite/stats.csv" ]; then
    continue
  fi

  test_schedules "$testsuite"
done
