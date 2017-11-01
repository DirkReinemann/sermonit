#!/bin/bash

# applications: apachectl, awk, echo, sed, tr

set -e
set -o pipefail

RESULT=$(apachectl -t -D DUMP_VHOSTS \
        | awk 'NR>1{ print "{\"name\":\""$1"\",\"domain\":\""$2"\",\"configuration\":\""$3"\"}" }' \
        | tr '\n' ',' | sed 's/,$//')

echo "[$RESULT]"

exit 0
