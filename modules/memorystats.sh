#!/bin/bash

# dependencies: awk, echo, free, grep, sed, tr

set -e
set -o pipefail

result=$(free -m | grep -v '^-' \
    | awk 'NR>1{ sub(/:/, "", $1); print "{\"type\":\""$1"\",\"total\":\""$2"\",\"used\":\""$3"\",\"free\":\""$4"\"}" }' \
    | tr '\n' ',' | sed 's/,$//'
)

echo "[$result]"

exit 0
