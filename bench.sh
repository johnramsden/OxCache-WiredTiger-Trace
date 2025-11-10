#!/bin/sh

LOG_DIR="$1"

wtperf -O /perf/ycsb-trace-create.wtperf -h /data/
touch "$LOG_DIR"
wtperf -O /perf/ycsb-trace.wtperf -h /data/ > "$LOG_DIR"

