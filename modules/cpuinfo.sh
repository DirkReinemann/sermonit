#!/bin/bash

# applications: awk, echo, lscpu, sed, tr

set -e
set -o pipefail

RESULT=$(lscpu | awk -F":" '{ gsub(/^[ \t]+/, "", $2); print "\""$1"\":\""$2"\"" }' | tr '\n' ',' \
        | sed 's/,$//')

echo "{$RESULT}"

exit 0
