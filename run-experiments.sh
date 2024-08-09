#!/bin/sh -u


EXPERIMENT_LOGS="./results/logs.log"
MYSQL_TESTSUITES="collations json"


setup_junit_testsuites() {
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
joda-time,b609d7d66d,https://github.com/JodaOrg/joda-time
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

    if ! [ -d junit-testsuites/crystalvc ]; then
	cp -r pradet-replication/experimental-study/crystalvc/ junit-testsuites/
    fi

    if ! [ -d junit-testsuites/xmlsecurity ]; then
	cp -r pradet-replication/experimental-study/xmlsecurity/ junit-testsuites/
    fi

    if ! [ -d junit-testsuites/dynoptic ]; then
	cat pradet-replication/experimental-study/dynoptic.partaa > dynoptic.tar.gz
	cat pradet-replication/experimental-study/dynoptic.partab >> dynoptic.tar.gz
	cat pradet-replication/experimental-study/dynoptic.partac >> dynoptic.tar.gz

	tar -xzf dynoptic.tar.gz
	rm -f dynoptic.tar.gz
	mv dynoptic/dynoptic junit-testsuites/
	rm -rf dynoptic
    fi
}


clone_repo() {
    local repo="$1"
    local directory="$(basename "$repo" | sed  's/\.git$//')"

    echo "Cloning $repo in $PWD/$directory..."

    if ! [ -d "./$directory" ]; then
	git clone "$repo"
    else
	cd "$directory"
	git pull
	cd ..
    fi
}


setup_gtdd() {
    clone_repo https://github.com/pako-23/gtdd.git

    cd gtdd
    make
    cd ..

    GTDD_EXEC="./gtdd/gtdd"
}


setup_pradet() {
    clone_repo https://github.com/gmu-swe/pradet-replication.git

    cd pradet-replication/

    clone_repo https://github.com/skappler/datadep-detector

    cd datadep-detector
    mvn clean install -DskipTests >/dev/null 2>&1
    cd ../..
}


setup() {
    if ! [ -d results ]; then
	mkdir -p results
    fi

    if ! [ -d results/timing ]; then
	mkdir -p results/timing
    fi

    setup_gtdd
    setup_pradet
    setup_junit_testsuites

    if ! [ -d "mysql-server" ]; then
	git clone https://github.com/mysql/mysql-server.git mysql-server
	cd mysql-server
	git checkout 596f0d238489a9cf9f43ce1ff905984f58d227b6
	cd ../..
    fi
}


get_runners() {
    local testsuite="$(basename "$1")"

    if echo "$MYSQL_TESTSUITES" | grep -q "\b$testsuite\b"; then
	expr "$(nproc --all)" / 2
	return
    fi

    nproc --all
}


get_testsuite_path() {
    local testsuite="$1"

    if [ -d "./testsuites/$testsuite" ]; then
	echo "./testsuites/$testsuite"
    elif [ -d "./junit-testsuites/$testsuite" ]; then
	echo "./junit-testsuites/$testsuite"
    else
	echo "./mysql-server"
    fi
}


run_testsuite() {
    local testsuite="$1"
    local graph="$2"
    local out_file="$3"
    local testsuite_path="$(get_testsuite_path "$testsuite")"

    for i in $(seq 1 3); do
	if [ -f "$testsuite_path/gtdd.yaml" ]; then
	    "$GTDD_EXEC" run --config "$testsuite_path/gtdd.yaml" \
			 --log-file "$out_file" \
			 -g "$graph" "$testsuite_path"
	else
	    "$GTDD_EXEC" run -r "$(get_runners "$testsuite")" \
			 --log-format json \
			 --log-file "$out_file" \
			 -g "$graph" "$testsuite_path"
	fi

	if [ "$?" -eq  0 ]; then
	    return
	fi
    done

    echo "Schedule $graph does not work" >> "$EXPERIMENT_LOGS"
}


validate_results() {
    local testsuite="$1"

    
    if ! [ -d "./results/timing/$testsuite" ]; then
	mkdir -p "./results/timing/$testsuite"
    fi

    for i in $(seq 1 10); do
	if [ -f "./results/timing/$testsuite/sequential-$i.json" ]; then
	    continue
	fi

	run_testsuite "$testsuite" '' \
		      "./results/timing/$testsuite/sequential-$i.json"
    done

    for graph in "./results/$testsuite/graph-"*; do
	if [ -f "./results/timing/$testsuite/$(basename "$graph")" ]; then
	    continue
	fi

	run_testsuite "$testsuite" \
		      "$graph" \
		      "./results/timing/$testsuite/$(basename "$graph")"
    done

    ./compute-times.py "./results/timing/$testsuite" "./results/timing/$testsuite/stats.csv"
}


find_dependencies_gtdd() {
    local testsuite="$1"
    local strategy="$2"

    local TIME="$(date  +"%d-%m-%y-%H-%M-%S")"
    local LOG_FILE="results/$testsuite/log-$strategy-$TIME.json"
    local GRAPH_FILE="results/$testsuite/graph-$strategy-$TIME.json"
    local SCHEDULES_FILE="results/$testsuite/schedules-$strategy-$TIME.json"
    local testsuite_path="$(get_testsuite_path "$testsuite")"

    local start_time="$(date -u +%s)"
    if [ -f "$testsuite_path/gtdd.yaml" ]; then
	"$GTDD_EXEC" deps --log-file "$LOG_FILE" \
		     --config  "$testsuite_path/gtdd.yaml" \
		     -s "$strategy" -o "$GRAPH_FILE" \
		     "$testsuite_path" >> "$EXPERIMENT_LOGS" 2>&1
    else
	"$GTDD_EXEC" deps -r "$(get_runners "$testsuite")" \
		     --log-format json \
		     --log debug \
		     --log-file "$LOG_FILE" \
		     -s "$strategy" -o "$GRAPH_FILE" \
		     "$testsuite_path" >> "$EXPERIMENT_LOGS" 2>&1
    fi
    local end_time="$(date -u +%s)"
    if [ "$?" -ne  0 ]; then
	return
    fi

    "$GTDD_EXEC" schedules  \
		 -i "$GRAPH_FILE" \
		 -o "$SCHEDULES_FILE" \
		 "$testsuite_path"

    ./compute-stats.py "$LOG_FILE" \
		       "$SCHEDULES_FILE" \
		       "results/$testsuite/stats-$strategy.csv" \
		       "$(expr "$end_time" - "$start_time")" >> "$EXPERIMENT_LOGS" 2>&1
}


find_dependencies_pradet() {
    local testsuite="./junit-testsuites/$testsuite"
    local strategy='pradet'

    local TIME="$(date  +"%d-%m-%y-%H-%M-%S")"
    local GRAPH_FILE="../../results/$(basename $testsuite)/graph-$strategy-$TIME.json"
    local SCHEDULES_FILE="../../results/$(basename $testsuite)/schedules-$strategy-$TIME.json"


    cd "$testsuite"

    if ! [ -f test-execution-order ]; then
	../../pradet-replication/scripts/extract_test_names_from_maven_output.sh >/dev/null
	mv maven_test_execution_order test-execution-order
    fi

    if ! [ -f reference-output.csv ]; then
	BIN=../../pradet-replication/bin \
	    ../../pradet-replication/scripts/generate_test_order.sh maven_test_execution_order >/dev/null
    fi

    if ! [ -f enumerations ]; then
	BIN=../../pradet-replication/bin \
	    ../../pradet-replication/scripts/bootstrap_enums.sh >/dev/null
    fi

    if ! [ -f package-filter ]; then
	BIN=../../pradet-replication/bin \
	    ../../pradet-replication/scripts/create_package_filter.sh
    fi

    local start_time="$(date -u +%s)"
    BIN=../../pradet-replication/bin \
	DATADEP_DETECTOR_HOME=../../pradet-replication/datadep-detector \
	../../pradet-replication/scripts/collect.sh >/dev/null
    mv reference-output.csv-* reference-output.csv
    mv run-order-* run-order
    BIN=../../pradet-replication/bin \
	DATADEP_DETECTOR_HOME=../../pradet-replication/datadep-detector \
	../../pradet-replication/scripts/refine.sh >/dev/null
    local end_time="$(date -u +%s)"

    ../../compute-pradet-graph.py run-order refined-deps.csv "$GRAPH_FILE"

    "../../$GTDD_EXEC" schedules -t junit  \
		 -i "$GRAPH_FILE" \
		 -o "$SCHEDULES_FILE" \
		 "$testsuite"

    local stats_file="../../results/$(basename $testsuite)/stats-$strategy.csv"
    local tests="$(cat run-order | wc -l)"
    local testsuite_runs="$(grep -E 'Finished after [0-9]+ iterations' pradet/refinement.log | grep -Eo '[0-9]+')"
    local test_runs="$(grep -Eo 'Executed [0-9]+ tests in total' pradet/refinement.log | grep -Eo '[0-9]+')"
    local longest_cost="$(python3 <<EOF
import json

with open("$SCHEDULES_FILE", "r") as fp:
     print(max(map(len, json.load(fp))))
EOF
)"
    local tot_cost="$(python3 <<EOF
import json

with open("$SCHEDULES_FILE", "r") as fp:
     print(sum(map(len, json.load(fp))))
EOF
)"

    if ! [ -f "$stats_file" ]; then
	echo 'n,test_suite_runs,tests_runned,time,longest_cost,tot_cost' > "$stats_file"
    fi

    echo "$tests,$testsuite_runs,$test_runs,$(expr "$end_time" - "$start_time"),$longest_cost,$tot_cost" >> "$stats_file"

    rm reference-output.csv
    rm run-order
    rm -rf pradet
    cd ../..
}


find_dependencies() {
    local testsuite="$1"
    local strategy="$2"

    if [ "$strategy" = 'pradet' ] && [ -d "./junit-testsuites/$(basename "$testsuite")" ]; then
	find_dependencies_pradet "$testsuite"
    else
	find_dependencies_gtdd "$testsuite" "$strategy"
    fi
}


setup_mysql_testsuite() {
    local testsuite="$1"

    cat > mysql-server/entrypoint.sh <<EOF
#!/bin/sh

if [ "$1" = '--list-tests']; then
  ./mysql-test-run.pl --print-testcases --suite=$testsuite | grep -E "^\[.*\]$" | tr -d "[" | tr -d "]"
else
  echo "\$@" | tr ' ' '\n' > list
  ./mysql-test-run.pl --do-test-list=list --xml-report=./results.xml >/dev/null 2>&1
  grep testcase results.xml | awk -F'"' '{
    for (i = 1; i <= NF; i++) {
      if (\$i ~ / suitename=/) {
        suitename=\$(i+1)
      } else if (\$i ~ / name=/) {
        name=\$(i+1)
      } else if (\$i ~ /status=/) {
        status=\$(i+1)
      }
    }
    if (suitename && name && status = "pass") {
      print suitename "." name " 1"
    } else if (suitename && name && status) {
      print suitename "." name " 0"
    }
  }'
fi
EOF

    chmod +x mysql-server/entrypoint.sh

    cat > mysql-server/Dockerfile <<EOF
FROM debian:bookworm

RUN useradd -s /bin/bash mysql \
    && apt-get update \
    && apt-get install -y cmake g++ openssl libssl-dev libncurses5-dev bison pkg-config perl \
    && mkdir -p /app/build \
    && chown -R mysql:mysql /app
USER mysql

WORKDIR /app
COPY --chown=mysql:mysql . .
WORKDIR /app/build

RUN cmake -DWITH_DEBUG=1 .. \
    && cmake --build . -j 10

WORKDIR /app/build/mysql-test

COPY --chown=mysql:mysql entrypoint.sh entrypoint.sh

ENTRYPOINT ["/app/build/mysql-test/entrypoint.sh"]
EOF
}


run_experiment() {
    local testsuite="$1"
    
    if [ -d "./results/$testsuite" ]; then
	return
    fi

    mkdir -p "results/$testsuite"

    if echo "$MYSQL_TESTSUITES" | grep -q "\b$testsuite\b"; then
	setup_mysql_testsuite "$testsuite"
    fi

    if ! "$GTDD_EXEC" build "$(get_testsuite_path "$testsuite")" >> "$EXPERIMENT_LOGS" 2>&1; then
	echo "Build for testsuite $testsuite failed" >> "$EXPERIMENT_LOGS"
	return
    fi

    for i in $(seq 1 10); do
	find_dependencies "$testsuite" 'pradet'
	find_dependencies "$testsuite" 'pfast'
	find_dependencies "$testsuite" 'mem-fast'
    done

    validate_results "$testsuite"
}


usage() {
    cat <<EOF
Usage: $(basename $0) [options] [testsuite]...

Arguments:
  [testsuite]...   The list of testsuites to include in the experiments. If no testsuite
                   is provided, it will ran the experiments on all the available testsuites

Options:
  -s, --setup      Do only the setup of all the testsuites
  -h, --help       Print help page
EOF
}



OPTS=$(getopt --options "hs" --long "help,setup" --name "$(basename $0)" -- "$@")
if [ "$?" -ne 0 ]; then
    usage
    exit 1
fi


eval set -- "$OPTS"

while true; do
    case "$1" in
	-h|--help)
	    usage
	    exit 0
	    ;;
	-s|--setup)
	    setup
	    exit 0
	    ;;
	--)
	    shift
	    break
	    ;;
	*)
	    usage
	    exit 1
	    ;;
    esac
done


setup

TESTSUITES=""
if [ "$#" -eq 0 ]; then
    TESTSUITES="$(ls ./testsuites/) $(ls ./junit-testsuites/) $MYSQL_TESTSUITES"
else
    for arg in "$@"; do
	TESTSUITES="${TESTSUITES} $(basename "$arg")"
    done
fi


for testsuite in $TESTSUITES; do
    run_experiment "$testsuite"
done
