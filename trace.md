# SPC traces for WiredTiger
Run `generate_trace.sh` to generate the trace. The three optionally customizable arguments are the location of the host log directory, the name of the log file, and the final generated output name.

The script builds a Docker container with `wt` and `wtperf`, and runs `bench.sh` which runs `wtperf` with the configs `bench/wtperf/runners/ycsb-trace-create.wtperf` and `bench/wtperf/runners/ycsb-trace.wtperf`. Then `filter.sh` transforms the trace into SPC format. 
