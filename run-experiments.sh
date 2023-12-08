#!/bin/sh

set -u

CURR_DIR="$PWD"
EXPERIMENT_LOGS="./results/logs.log"


get_appurl() {
  local testsuite="$1"

  local port="$(grep 'test:' "./testsuites/$testsuite/docker-compose.yml" \
    | grep -oE 'http://localhost(:[0-9]+)?' \
    | grep -oE '[0-9]+')"

  if [ -z "$port" ]; then
    echo 'http://app'
  else
    echo "http://app:$port"
  fi
}

run_testsuite() {
  local testsuite="$1"
  local graph="$2"
  local out_file="$3"
  local runners="$(expr "$(nproc --all)" \* 3 / 4)"

  for i in $(seq 1 3); do
    "$GTDD_EXEC" run --format json --log-file "$out_file" \
      -v "app_url=$(get_appurl "$testsuite")" \
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
    -v "app_url=$(get_appurl "$testsuite")" \
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

  if ! "$GTDD_EXEC" build -t java-selenium "testsuites/$testsuite" >> "$EXPERIMENT_LOGS" 2>&1; then
    return
  fi

  for i in $(seq 1 10); do
    if [ -f "./results/timing/$testsuite/sequential-$i.json" ]; then
      continue
    fi

    run_testsuite "$testsuite" '' "./results/timing/$testsuite/sequential-$i.json"
  done

  for schedule in "./results/$testsuite/schedules-"*; do
    graph="$(echo "$schedule" | sed s/schedules-/graph-/)"
    if [ -f "./results/timing/$testsuite/$(basename "$graph")" ]; then
      continue
    fi

    run_testsuite "$testsuite" "$graph" "./results/timing/$testsuite/$(basename "$graph")"
  done

  ./compute-times.py "./results/timing/$testsuite" "./results/timing/$testsuite/stats.csv"
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
  test_schedules "$testsuite"
done
