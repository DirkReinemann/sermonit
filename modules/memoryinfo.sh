#!/bin/bash

# applications: awk, cat, echo, sed, tr

set -e
set -o pipefail

RESULT=$(cat /proc/meminfo | awk -F": " '{ gsub(/^[ \t]+/, "", $2); print "\""$1"\":\""$2"\"" }' \
        | tr '\n' ',' | sed 's/,$//')

echo "{$RESULT}"

exit 0
