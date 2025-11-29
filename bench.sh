#!/bin/sh

LOG_FILE="$1"
LOG_PATH="/logs/$LOG_FILE"
DB_PATH="/data/db"

# Check if database already exists
if [ -f "$DB_PATH/WiredTiger" ] || [ -f "$DB_PATH/WiredTiger.basecfg" ]; then
    echo "Database already exists in $DB_PATH, skipping creation step"
else
    echo "Creating new database in $DB_PATH"
    wtperf -O /perf/ycsb-trace-create.wtperf -h "$DB_PATH"
fi

touch "$LOG_PATH"
wtperf -O /perf/ycsb-trace.wtperf -h "$DB_PATH" | ./filter.sh > "$LOG_PATH"

