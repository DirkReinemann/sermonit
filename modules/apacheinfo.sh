#!/bin/bash

# dependencies: apachectl, awk, echo, grep, sed, tr

set -e
set -o pipefail

result1=$(apachectl -v | awk -F":" '{ gsub(/^[ \t]+/, "", $2); print "\""$1"\":\""$2"\"" }' | tr '\n' ',' | sed 's/,$//')

result2=$(apachectl -t -D DUMP_RUN_CFG | grep -v '^Define' | sed 's/"//g' | \
    awk -F":" '{ gsub(/^[ \t]+/, "", $2); print "\""$1"\":\""$2"\"" }' | tr '\n' ',' | sed 's/,$//'
)

echo "{$result1,$result2}"

exit 0
