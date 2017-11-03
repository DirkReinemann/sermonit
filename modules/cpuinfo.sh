#!/bin/bash

# dependencies: awk, echo, lscpu, sed, tr

set -e
set -o pipefail

result=$(lscpu | awk -F":" '{ gsub(/^[ \t]+/, "", $2); print "\""$1"\":\""$2"\"" }' | tr '\n' ','  | sed 's/,$//')

echo "{$result}"

exit 0
