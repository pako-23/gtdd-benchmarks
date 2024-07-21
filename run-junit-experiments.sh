#!/bin/sh -u




EXPERIMENT_LOGS="./results/logs.log"



clone_repos() {
    REPOS="
photoplatform-sdf,3a7d9e76d9,https://github.com/VincSch/photoplatform-sdf.git
DiskLruCache,3aa62867b2,https://github.com/JakeWharton/DiskLruCache.git
indextank-engine,f2354fe9db,https://github.com/linkedin/indextank-engine.git
Bateman,08db4a68fb,https://github.com/fearofcode/bateman.git
dspot,fe822567e9,https://github.com/STAMP-project/dspot.git
webbit,f628a7a3ff,https://github.com/webbit/webbit.git
stream-lib,5868141735,https://github.com/addthis/stream-lib.git
http-request,2d62a3e9da,https://github.com/kevinsawicki/http-request.git
okio,20e259c08a,https://github.com/square/okio.git
togglz,7a1af66c0b,https://github.com/togglz/togglz.git
Bukkit,574f7a8c6c,https://github.com/Bukkit/Bukkit.git
jackson-core,d04bea92fd,https://github.com/FasterXML/jackson-core.git
jsoup,f28c024ba1,https://github.com/jhy/jsoup.git
dynjs,4bc6715eff,https://github.com/dynjs/dynjs.git
"
    if ! [ -d junit-testsuites ]; then
	mkdir junit-testsuites
    fi

    for line in $REPOS; do
	directory="$(echo $line | cut -d',' -f1)"
	commitid="$(echo $line | cut -d',' -f2)"
	repository="$(echo $line | cut -d',' -f3)"
	if ! [ -d "junit-testsuites/$directory" ]; then
	    git clone "$repository" "junit-testsuites/$directory"
	    cd "junit-testsuites/$directory"
	    git checkout "$commitid"
	    cd ../..
	fi
    done
}


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

    clone_repos
}


run_testsuite() {
    local testsuite="$1"
    local graph="$2"
    local out_file="$3"

    for i in $(seq 1 3); do

	"$GTDD_EXEC" run -t junit -r 10 \
		     --log-file "$out_file" \
		     -s "$graph" \
		     "junit-testsuites/$testsuite"
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

    "$GTDD_EXEC" deps --log-file "$LOG_FILE" -r 14 \
		 -s "$strategy" -o "$GRAPH_FILE" \
		 "junit-testsuites/$testsuite" >> "$EXPERIMENT_LOGS" 2>&1
    if [ "$?" -ne  0 ]; then
	return
    fi

    "$GTDD_EXEC" schedules -t junit \
		 -i "$GRAPH_FILE" \
		 -o "$SCHEDULES_FILE" \
		 "junit-testsuites/$testsuite"

    ./compute-stats.py "$LOG_FILE" \
		       "$SCHEDULES_FILE" \
		       "results/$testsuite/stats-$strategy.csv"  >> "$EXPERIMENT_LOGS" 2>&1
}


run_experiment() {
    local testsuite="$1"

    if ! "$GTDD_EXEC" build -t junit "junit-testsuites/$testsuite" >> "$EXPERIMENT_LOGS" 2>&1; then
	return
    fi

    if ! [ -d "results/$testsuite" ]; then
	mkdir -p "results/$testsuite"
    fi

    for i in $(seq 1 10); do
	single_iteration "$testsuite" 'pfast'
    done
}


setup

TESTSUITES=""

if [ "$#" -eq 0 ]; then
    TESTSUITES="$(ls ./junit-testsuites/)"
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

