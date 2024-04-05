#!/bin/sh -u


EXPERIMENT_LOGS="./results/logs.log"


setup() {
    if ! [ -d ./gtdd ]; then
	git clone https://github.com/pako-23/gtdd.git
    else
	cd gtdd
	git pull
	cd ..
    fi

    cd gtdd
    make
    cd ..

    GTDD_EXEC="./gtdd/gtdd"

    if ! [ -d results ]; then
	mkdir -p results
    fi
    if ! [ -d results/timing ]; then
	mkdir -p results/timing
    fi
}


run_testsuite() {
    local testsuite="$1"
    local graph="$2"
    local out_file="$3"

    for i in $(seq 1 3); do

	"$GTDD_EXEC" run --config "testsuites/$testsuite/gtdd.yaml" \
		     --log-file "$out_file" \
		     -s "$graph" \
		     "testsuites/$testsuite"
	if [ "$?" -eq  0 ]; then
	    return 0
	fi
  done

  echo "Schedule $graph does not work" >> "$EXPERIMENT_LOGS"
  return 1
}


test_schedules() {
    local testsuite="$1"
    
    if ! [ -d "./results/timing/$testsuite" ]; then
	mkdir -p "./results/timing/$testsuite"
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


single_iteration() {
    local testsuite="$1"
    local strategy="$2"
    

    local TIME="$(date  +"%d-%m-%y-%H-%M-%S")"
    local LOG_FILE="results/$testsuite/log-$strategy-$TIME.json"
    local GRAPH_FILE="results/$testsuite/graph-$strategy-$TIME.json"
    local SCHEDULES_FILE="results/$testsuite/schedules-$strategy-$TIME.json"

    "$GTDD_EXEC" deps --log-file "$LOG_FILE" \
		 --config  "testsuites/$testsuite/gtdd.yaml" \
		 -s "$strategy" -o "$GRAPH_FILE" \
		 "testsuites/$testsuite" >> "$EXPERIMENT_LOGS" 2>&1
    if [ "$?" -ne  0 ]; then
	return
    fi

    "$GTDD_EXEC" schedules -t java-selenium  \
		 -i "$GRAPH_FILE" \
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
	single_iteration "$testsuite" 'pfast'
	single_iteration "$testsuite" 'pradet'
    done
}


setup

TESTSUITES=""

if [ "$#" -eq 0 ]; then
    TESTSUITES="$(ls ./testsuites/)"
else
    for arg in "$@"; do
	TESTSUITES="${TESTSUITES} $(basename "$arg")"
    done
fi

for testsuite in $TESTSUITES; do
    if [ -d "./results/$testsuite" ]; then
	continue
    fi

    run_experiment "$testsuite"
    test_schedules "$testsuite"
done
