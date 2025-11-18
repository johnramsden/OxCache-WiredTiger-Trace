#!/bin/sh

LOG_FILE="$1"
LOG_PATH="/logs/$LOG_FILE"

wtperf -O /perf/ycsb-trace-create.wtperf -h /data/
touch "$LOG_PATH"
wtperf -O /perf/ycsb-trace.wtperf -h /data/ | ./filter.sh > "$LOG_PATH"

