#!/bin/bash

# dependencies: apachectl, awk, echo, sed, tr

set -e
set -o pipefail

result=$(apachectl -t -D DUMP_VHOSTS | \
    awk 'NR>1{ print "{\"name\":\""$1"\",\"domain\":\""$2"\",\"configuration\":\""$3"\"}" }' | \
    tr '\n' ',' | \
    sed 's/,$//'
)

echo "[$result]"

exit 0
