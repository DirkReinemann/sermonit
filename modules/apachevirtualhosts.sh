#!/bin/bash

# dependencies: apachectl, awk, echo, sed, tr

set -e
set -o pipefail

result=$(apachectl -t -D DUMP_VHOSTS | \
    awk '{ gsub(/\(/, "", $5); gsub(/\)/, "", $5); if ($2 ~ /^[0-9]+$/) print "{\"domain\":\""$4"\",\"port\":\""$2"\",\"configuration\":\""$5"\"}" }' | \
    tr '\n' ',' | \
    sed 's/,$//'
)

echo "[$result]"

exit 0
