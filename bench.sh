#!/bin/sh

LOG_DIR="/logs/data_log.txt"

wtperf -O /perf/ycsb-trace-create.wtperf -h /data/
touch "$LOG_DIR"
wtperf -O /perf/ycsb-trace.wtperf -h /data/ > "$LOG_DIR"
