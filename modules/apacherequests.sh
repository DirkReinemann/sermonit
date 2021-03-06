#!/bin/bash

# dependencies: apachectl, awk, date, echo, grep, wc

set -e
set -o pipefail

logs=$(apachectl -S 2>/dev/null | grep 'Main ErrorLog' | awk -vFS=": " '{ print $2 }' | sed 's/"//g' | xargs dirname)
date=$(date "+%d/%b/%Y:%H:%M:%S")

result=$( (grep -r $date $logs/* 2>/dev/null || printf "") | wc -l | awk '{ print "{\"type\":\"total\",\"requests\":\""$1"\"}" }')

echo "[$result]"

exit 0
