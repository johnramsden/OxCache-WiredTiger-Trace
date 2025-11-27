#!/bin/bash

SECTOR_SIZE=4096

awk -v SECTOR_SIZE="$SECTOR_SIZE" '
    function err(msg) {
        print msg > "/dev/stderr"
        exit 1
    }

    # Extract timestamp string "sec.usec" from a line, or "" if not found
    function extract_ts(line,   a) {
        if (match(line, /\[([0-9]+):([0-9]+)\]/, a))
            return a[1] "." a[2]
        return ""
    }

    BEGIN {
        START_TIME = -1.0
    }

    {
        # Try to grab a timestamp from the current line
        ts_str = extract_ts($0)

        # First timestamp we ever see becomes START_TIME
        if (START_TIME < 0 && ts_str != "")
            START_TIME = ts_str + 0.0
    }

    /file:oxcache_table\.wt,/ {
        # We must have a timestamp for this line
        if (ts_str == "")
            ts_str = extract_ts($0)
        if (ts_str == "")
            err("Error: missing timestamp")

        ts = ts_str + 0.0

        # offset
        offset = 0
        if (match($0, /offset=([0-9]+)/, c))
            offset = c[1] / SECTOR_SIZE
        else if (match($0, /off ([0-9]+)/, c))
            offset = c[1] / SECTOR_SIZE
        else
            err("Error: missing offset/off")

        # length
        len = 0
        if (match($0, /len=([0-9]+)/, d))
            len = d[1]
        else if (match($0, /size ([0-9]+)/, d))
            len = d[1]
        else
            err("Error: missing len/size")

        # operation
        if (match($0, /WT_VERB_(READ|WRITE)/, e))
            op = (e[1] == "READ") ? "R" : "W"
        else
            err("Error: missing WT_VERB_(READ|WRITE)")

        if (START_TIME < 0)
            err("Error: START_TIME was never set")

        printf "0,%s,%s,%s,%f\n", offset, len, op, (ts - START_TIME)
    }
'
