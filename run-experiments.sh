#!/bin/sh -u


EXPERIMENT_LOGS="./results/logs.log"
MYSQL_TESTSUITES="audit_null collations jp json gcol gis innodb_zip information_schema"


setup_junit_testsuite() {
    local testsuite="$1"

    cd junit-testsuites/"$testsuite"

    if ! [ -f entrypoint.sh ]; then
	cat > entrypoint.sh <<EOF
#!/bin/sh

if [ "\$1" = '--list-tests' ]; then
   cat testsuite
else
  CLASSES_PATH="\$(find . -name classes -type d | paste -sd ':')"
  TEST_CLASSES_PATH="\$(find . -name test-classes -type d | paste -sd ':')"
  java -cp "/app/junit-4.12.jar:\$(cat merged-cp.txt):\$TEST_CLASSES_PATH:\$CLASSES_PATH:" CustomRunner "\$@"  >/dev/null 2>&1
  cat summary.txt
fi
EOF
	chmod +x entrypoint.sh
    fi
    if ! [ -f testsuite ]; then
	docker run -v $PWD:/app maven:3.6.1-jdk-8 bash -c 'cd /app && mvn clean test' >/dev/null 2>&1
	find . -name TEST*.xml -exec grep -E '<testcase |<skipped|<failure ' {} \; |
	     sed '$!N;/<skipped\/>\|<failure /!P;D' | grep -v '<failure' | awk -F'"' '{
	  for (i = 1; i <= NF; i++) {
            if ($i ~ /classname=/) {
	      classname=$(i+1)
    	    } else if ($i ~ /name=/) {
      	      name=$(i+1)
    	    }
  	  }
  	  if (classname && name) { print classname "#" name }
	}' | uniq > testsuite
    fi

    if ! [ -f CustomRunner.java ]; then
	cat > CustomRunner.java <<EOF
import org.junit.runner.JUnitCore;
import org.junit.runner.Request;
import org.junit.runner.Result;
import java.io.PrintWriter;
import java.io.FileWriter;
import java.io.IOException;

public class CustomRunner {
    public static void main(final String[] args) throws ClassNotFoundException {
        JUnitCore core = new JUnitCore();
        final boolean[] results = new boolean[args.length];

	for (int i = 0; i < args.length; ++i) {
            String[] parts = args[i].split("#");
            Request request = Request.method(Class.forName(parts[0]), parts[1]);

	    Result result = core.run(request);
	    results[i] = result.wasSuccessful();
        }

	try {
	    PrintWriter out = new PrintWriter(new FileWriter("summary.txt"));

	    for (int i = 0; i < results.length; ++i)
		out.println(String.format("%s %d", args[i], results[i] ? 1 : 0));

	    out.close();
        } catch (IOException e) {
            System.exit(1);
        }
        System.exit(0);
    }
}
EOF
    fi

    if ! [ -f Dockerfile ]; then
	cat > Dockerfile <<EOF
FROM maven:3.6.1-jdk-8

COPY . /app
WORKDIR /app

RUN curl -O https://repo1.maven.org/maven2/junit/junit/4.12/junit-4.12.jar
RUN mvn compile test-compile
RUN mvn dependency:build-classpath -DincludeScope=test -Dmdep.outputFile=cp.txt
RUN paste -d: \$(find .  -name cp.txt ! -size 0) | tr -d '\n' > merged-cp.txt
RUN javac -cp "/app/junit-4.12.jar:" CustomRunner.java

ENTRYPOINT ["/app/entrypoint.sh"]
EOF
    fi

    cd ../..
}


setup_junit_testsuites() {
    REPOS="
Bateman,08db4a68fb,https://github.com/fearofcode/bateman.git
Bukkit,574f7a8c6c,https://github.com/Bukkit/Bukkit.git
DiskLruCache,3aa62867b2,https://github.com/JakeWharton/DiskLruCache.git
dynjs,4bc6715eff,https://github.com/dynjs/dynjs.git
http-request,2d62a3e9da,https://github.com/kevinsawicki/http-request.git
indextank-engine,f2354fe9db,https://github.com/linkedin/indextank-engine.git
jackson-core,29e8dc34bd,https://github.com/FasterXML/jackson-core.git
jsoup,f28c024ba1,https://github.com/jhy/jsoup.git
okio,895452f52b,https://github.com/square/okio.git
photoplatform-sdf,3a7d9e76d9,https://github.com/VincSch/photoplatform-sdf.git
stream-lib,5868141735,https://github.com/addthis/stream-lib.git
webbit,f628a7a3ff,https://github.com/webbit/webbit.git
"


    mkdir -p junit-testsuites/

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
	setup_junit_testsuite "$directory"
    done

    if ! test -d junit-testsuites/xmlsecurity; then
	cd junit-testsuites/
	clone_repo https://github.com/gmu-swe/pradet-replication.git

	cp -r pradet-replication/experimental-study/xmlsecurity/ xmlsecurity
	rm -rf pradet-replication/
	cd ..
    fi

    setup_junit_testsuite xmlsecurity
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


setup() {
    if ! [ -d results ]; then
	mkdir -p results
    fi

    if ! [ -d results/timing ]; then
	mkdir -p results/timing
    fi

    setup_gtdd
    setup_junit_testsuites

    if ! [ -d "mysql-server" ]; then
	git clone https://github.com/mysql/mysql-server.git mysql-server
	cd mysql-server
	git checkout 596f0d238489a9cf9f43ce1ff905984f58d227b6
	cd ../..
    fi
}


get_runners() {
    expr "$(nproc --all)" / 2
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
    local graph=""
    if [ -n "$2" ]; then
	graph="-g $2"
    fi
    local out_file="$3"
    local testsuite_path="$(get_testsuite_path "$testsuite")"

    for i in $(seq 1 3); do
	if [ -f "$testsuite_path/gtdd.yaml" ]; then
	    "$GTDD_EXEC" run --config $testsuite_path/gtdd.yaml \
			 --log-file $out_file \
			 $graph $testsuite_path
	else
	    "$GTDD_EXEC" run --log-format json \
			 --log-file $out_file \
			 $graph $testsuite_path
	fi

	if [ "$?" -eq  0 ]; then
	    return
	fi
	rm $out_file
    done

    echo "Schedule $graph does not work" >> "$EXPERIMENT_LOGS"
}


validate_results() {
    local testsuite="$1"

    if ! [ -d "./results/timing/$testsuite" ]; then
	mkdir -p "./results/timing/$testsuite"
    fi

    if echo "$MYSQL_TESTSUITES" | grep -q "\b$testsuite\b"; then
	setup_mysql_testsuite "$testsuite" '--valgrind'
	docker system prune -f -a
	if ! "$GTDD_EXEC" build "$(get_testsuite_path "$testsuite")" >> "$EXPERIMENT_LOGS" 2>&1; then
	    echo "Build for testsuite $testsuite failed" >> "$EXPERIMENT_LOGS"
	    return
	fi
    fi

    for i in $(seq 1 10); do
	if [ -f "./results/timing/$testsuite/sequential-$i.json" ]; then
	    continue
	fi

	run_testsuite "$testsuite" '' \
		      "./results/timing/$testsuite/sequential-$i.json"
    done

    for graph in $(ls "./results/$testsuite/" | grep graph-); do
	if [ -f "./results/timing/$testsuite/$(basename "$graph")" ]; then
	    continue
	fi

	run_testsuite "$testsuite" \
		      "./results/$testsuite/$graph" \
		      "./results/timing/$testsuite/$(basename "$graph")"
    done

    ./compute-times.py "./results/timing/$testsuite" "./results/timing/$testsuite/stats.csv"
}


find_dependencies() {
    local testsuite="$1"
    local strategy="$2"

    local TIME="$(date  +"%d-%m-%y-%H-%M-%S")"
    local LOG_FILE="results/$testsuite/log-$strategy-$TIME.json"
    local GRAPH_FILE="results/$testsuite/graph-$strategy-$TIME.json"
    local SCHEDULES_FILE="results/$testsuite/schedules-$strategy-$TIME.json"
    local testsuite_path="$(get_testsuite_path "$testsuite")"

    local start_time="$(date -u +%s)"
    if [ -f "$testsuite_path/gtdd.yaml" ]; then
	timeout 24h "$GTDD_EXEC" deps --log-file "$LOG_FILE" \
		     --config  "$testsuite_path/gtdd.yaml" \
		     -s "$strategy" -o "$GRAPH_FILE" \
		     "$testsuite_path" >> "$EXPERIMENT_LOGS" 2>&1
    else
	timeout 24h "$GTDD_EXEC" deps -r "$(get_runners "$testsuite")" \
		     --log-format json \
		     --log debug \
		     --log-file "$LOG_FILE" \
		     -s "$strategy" -o "$GRAPH_FILE" \
		     "$testsuite_path" >> "$EXPERIMENT_LOGS" 2>&1
    fi
    local exit_status="$?"
    local end_time="$(date -u +%s)"
    if [ "$exit_status" -ne  0 ]; then
	docker rm -f $(docker ps -aq)
	docker network prune -f
	./compute-stats.py "$LOG_FILE" \
		       "$SCHEDULES_FILE" \
		       "results/$testsuite/stats-$strategy.csv" \
		       "$(expr "$end_time" - "$start_time")" >> "$EXPERIMENT_LOGS" 2>&1
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


setup_mysql_testsuite() {
    local testsuite="$1"
    local run_options="$2"

    cat > mysql-server/entrypoint.sh <<EOF
#!/bin/sh

if [ "\$1" = '--list-tests' ]; then
   cat testsuite
else
  echo "\$@" | tr ' ' '\n' > list
  ./mysql-test-run.pl --do-test-list=list $run_options --big-test --xml-report=./results.xml >/dev/null 2>&1
  for test_name in \$(cat list); do
    testcase="\$(grep "name=\\"\$(echo "\$test_name" | awk -F'.' '{print \$2}')\\"" results.xml)"
    result='0'
    if echo "\$testcase" | grep -q 'status="pass"'; then
	result='1'
    fi
    echo "\$test_name \$result"
  done
fi
EOF

    chmod +x mysql-server/entrypoint.sh

    cat > mysql-server/Dockerfile <<EOF
FROM debian:bookworm

RUN useradd -s /bin/bash mysql \
    && apt-get update \
    && apt-get install -y cmake g++ openssl libssl-dev libncurses5-dev bison pkg-config perl valgrind \
    && mkdir -p /app/build \
    && chown -R mysql:mysql /app
USER mysql

WORKDIR /app
COPY --chown=mysql:mysql . .
WORKDIR /app/build

RUN cmake -DWITH_DEBUG=1 .. \
    && cmake --build . -j 10

WORKDIR /app/build/mysql-test

RUN ./mysql-test-run.pl --suite=$testsuite --big-test | grep pass | awk '{print \$3}' | grep -E '^[0-9a-zA-Z.]+' > testsuite

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
	setup_mysql_testsuite "$testsuite" ''
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
