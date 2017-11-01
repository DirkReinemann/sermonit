#!/bin/bash

# applications: apachectl, awk, echo, grep, sed, tr

set -e
set -o pipefail

RESULT1=$(apachectl -v | awk -F":" '{ gsub(/^[ \t]+/, "", $2); print "\""$1"\":\""$2"\"" }' | tr '\n' ',' \
        | sed 's/,$//')

RESULT2=$(apachectl -t -D DUMP_RUN_CFG | grep -v '^Define' | sed 's/"//g' \
        | awk -F":" '{ gsub(/^[ \t]+/, "", $2); print "\""$1"\":\""$2"\"" }' | tr '\n' ',' | sed 's/,$//')

echo "{$RESULT1,$RESULT2}"

exit 0
