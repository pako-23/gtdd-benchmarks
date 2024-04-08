# gtdd benchmarks

A benchmark to for [gtdd].

----
## To run the benchmark

Ensure you have a working [Go environment].  To run the entire
benchmark run the following commands.

```bash
https://github.com/pako-23/gtdd-benchmarks.git
cd gtdd-benchmarks
./run-experiments.sh
```

To run the benchmark only against some of the test suites, run the
following command.

```bash
./run-experiments.sh ./testsuites/testsuite1 ./testsuites/testsuite2 ...
```

To generate the plots from the benchmarks, ensure you have [gnuplot]
installed, and run the following command.

```bash
./make-plots.sh
```

[Go environment]: https://go.dev/doc/install
[gnuplot]: http://www.gnuplot.info/
[gtdd]: https://github.com/pako-23/gtdd
