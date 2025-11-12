#!/bin/bash

DATA_LOCATION="$1"
SECTOR_SIZE=4096
START_TIME=$(awk 'match($0, /\[([0-9]+):([0-9]+)\]/, a) { print a[1] "." a[2]; exit }' "$DATA_LOCATION")

awk -v SECTOR_SIZE="$SECTOR_SIZE" -v START_TIME="$START_TIME" '
    function err() {
        print "Error"
	exit
    }

   /file:oxcache_table\.wt,/ {

    # Parse timestamp
    if (match($0, /\[([0-9]+):([0-9]+)\]/, a))
        ts = a[1] "." a[2] + 0.0
    else
	err()

    offset = 0
    if (match($0, /offset=([0-9]+)/, c))
        offset = c[1] / SECTOR_SIZE
    else if (match($0, /off ([0-9]+)/, c))
        offset = c[1] / SECTOR_SIZE
    else
	err()

    len = 0
    if (match($0, /len=([0-9]+)/, d))
        len = d[1]
    else if (match($0, /size ([0-9]+)/, d))
    	len = d[1]
    else
	err()

    if (match($0, /WT_VERB_(READ|WRITE)/, e))
        op = (e[1] == "READ") ? "R" : "W"
    else
	err()

    printf "0,%s,%s,%s,%f\n", offset, len, op, (ts - START_TIME)
}
' "$DATA_LOCATION"
