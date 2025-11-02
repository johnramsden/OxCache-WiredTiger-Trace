#!/bin/sh

wtperf -O /perf/ycsb-trace-create.wtperf -h /data/
wtperf -O /perf/ycsb-trace.wtperf -h /data/ > "data_log.txt"
