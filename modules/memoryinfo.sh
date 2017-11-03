#!/bin/bash

# dependencies: awk, cat, echo, sed, tr

set -e
set -o pipefail

result=$(cat /proc/meminfo | awk -F": " '{ gsub(/^[ \t]+/, "", $2); print "\""$1"\":\""$2"\"" }' | tr '\n' ',' \
    | sed 's/,$//'
)

echo "{$result}"

exit 0
