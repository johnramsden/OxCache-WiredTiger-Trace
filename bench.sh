#!/bin/sh

wtperf -O /perf/ycsb-trace-create.wtperf -h /data/
touch /data/data_log.txt
wtperf -O /perf/ycsb-trace.wtperf -h /data/ > "/data/data_log.txt"
