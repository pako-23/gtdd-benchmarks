#!/bin/sh -u


EXPERIMENT_LOGS="./results/logs.log"
MYSQL_TESTSUITES="collations"


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
    clone_repo https://github.com/mysql/mysql-server.git
}


run_testsuite() {
    local testsuite="$1"
    local testsuite_type="$2"
    local graph="$3"
    local out_file="$4"

    for i in $(seq 1 3); do
	if [ -f "$testsuite/gtdd.yaml" ]; then
	    "$GTDD_EXEC" run --config "$testsuite/gtdd.yaml" \
			 --type "$testsuite_type" \
			 --log-file "$out_file" \
			 -s "$graph" "$testsuite"
	else
	    "$GTDD_EXEC" run --type "$testsuite_type" \
			 -r "$(nproc --all)" \
			 --log-format json \
			 --log-file "$out_file" \
			 -s "$graph" "$testsuite"
	fi

	if [ "$?" -eq  0 ]; then
	    return
	fi
    done

    echo "Schedule $graph does not work" >> "$EXPERIMENT_LOGS"
}


validate_results() {
    local testsuite="$1"
    local testsuite_type="$2"
    local testsuite_name="$(basename $1)"
    
    if ! [ -d "./results/timing/$testsuite_name" ]; then
	mkdir -p "./results/timing/$testsuite_name"
    fi

    for i in $(seq 1 10); do
	if [ -f "./results/timing/$testsuite_name/sequential-$i.json" ]; then
	    continue
	fi

	run_testsuite "$testsuite" \
		      "$testsuite_type" '' \
		      "./results/timing/$testsuite_name/sequential-$i.json"
    done

    for graph in "./results/$testsuite_name/graph-"*; do
	if [ -f "./results/timing/$testsuite_name/$(basename "$graph")" ]; then
	    continue
	fi

	run_testsuite "$testsuite" \
		      "$testsuite_type" \
		      "$graph" \
		      "./results/timing/$testsuite_name/$(basename "$graph")"
    done

    ./compute-times.py "./results/timing/$testsuite_name" "./results/timing/$testsuite_name/stats.csv"
}


find_dependencies_gtdd() {
    local testsuite="$1"
    local testsuite_type="$2"
    local strategy="$3"

    local TIME="$(date  +"%d-%m-%y-%H-%M-%S")"
    local LOG_FILE="results/$(basename $testsuite)/log-$strategy-$TIME.json"
    local GRAPH_FILE="results/$(basename $testsuite)/graph-$strategy-$TIME.json"
    local SCHEDULES_FILE="results/$(basename $testsuite)/schedules-$strategy-$TIME.json"

    local start_time="$(date -u +%s)"
    if [ -f "$testsuite/gtdd.yaml" ]; then
	"$GTDD_EXEC" deps -t "$testsuite_type" --log-file "$LOG_FILE" \
		     --config  "$testsuite/gtdd.yaml" \
		     -s "$strategy" -o "$GRAPH_FILE" \
		     "$testsuite" >> "$EXPERIMENT_LOGS" 2>&1
    else
	"$GTDD_EXEC" deps -t "$testsuite_type" -r "$(nproc --all)" \
		     --log-format json \
		     --log debug \
		     --log-file "$LOG_FILE" \
		     -s "$strategy" -o "$GRAPH_FILE" \
		     "$testsuite" >> "$EXPERIMENT_LOGS" 2>&1
    fi
    local end_time="$(date -u +%s)"
    if [ "$?" -ne  0 ]; then
	return
    fi

    "$GTDD_EXEC" schedules -t "$testsuite_type"  \
		 -i "$GRAPH_FILE" \
		 -o "$SCHEDULES_FILE" \
		 "$testsuite"

    ./compute-stats.py "$LOG_FILE" \
		       "$SCHEDULES_FILE" \
		       "results/$(basename $testsuite)/stats-$strategy.csv" \
		       "$(expr "$end_time" - "$start_time")" >> "$EXPERIMENT_LOGS" 2>&1
}


find_dependencies_pradet() {
    local testsuite="$1"
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
    local testsuite_type="$2"
    local strategy="$3"

    if [ "$strategy" = 'pradet' ] && [ "$testsuite_type" = 'junit' ]; then
	find_dependencies_pradet "$testsuite"
    else
	find_dependencies_gtdd "$testsuite" "$testsuite_type" "$strategy"
    fi
}


setup_mysql_testsuite() {
    local testsuite="$1"

    cat > mysql-server/list_tests.sh <<EOF
#!/bin/sh

./mysql-test-run.pl --print-testcases --suite=$testsuite | grep -E "^\[.*\]$" | tr -d "[" | tr -d "]"
EOF

    cat > mysql-server/run_tests.sh <<EOF
#!/bin/sh

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
EOF

    chmod +x mysql-server/run_tests.sh
    chmod +x mysql-server/list_tests.sh

    cat > mysql-server/Dockerfile <<EOF
FROM debian:bookworm

RUN useradd -s /bin/bash mysql \
    && apt-get update \
    && apt-get install -y cmake g++ openssl libssl-dev libncurses5-dev bison pkg-config perl


WORKDIR /app
COPY . .

WORKDIR /app/build

RUN cmake -DWITH_DEBUG=1 .. \
    && cmake --build . -j 10

WORKDIR /app/build/mysql-test

COPY list_tests.sh list_tests.sh
COPY run_tests.sh run_tests.sh

USER mysql
EOF
}


run_experiment() {
    local testsuite="$1"
    
    if [ -d "./results/$testsuite" ]; then
	return
    fi

    mkdir -p "results/$testsuite"

    if echo "$MSQL_TESTSUITES" | grep -q "\b$testsuite\b"; then
	setup_mysql_testsuite "$testsuite"
	return
    fi

    local testsuite_type=""
    if [ -d "./testsuites/$testsuite" ]; then
	testsuite_type="java-selenium"
	testsuite="./testsuites/$testsuite"
    else if [ -d "./junit-testsuites/$testsuite" ]; then
	testsuite_type="junit"
	testsuite="./junit-testsuites/$testsuite"
    fi

    if ! "$GTDD_EXEC" build -t "$testsuite_type" "$testsuite" >> "$EXPERIMENT_LOGS" 2>&1; then
	echo "Build for testsuite $testsuite failed" >> "$EXPERIMENT_LOGS"
	return
    fi

    for i in $(seq 1 10); do
	find_dependencies "$testsuite" "$testsuite_type" 'pradet'
	find_dependencies "$testsuite" "$testsuite_type" 'pfast'
	find_dependencies "$testsuite" "$testsuite_type" 'mem-fast'
    done

    validate_results "$testsuite" "$testsuite_type"
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
