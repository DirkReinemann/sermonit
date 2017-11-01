#!/bin/bash

# applications: awk, echo, netstat, sed, tr

set -e
set -o pipefail

RESULT=$(netstat -tpna4 \
        | awk 'NR>2 { print "{\"local\":\""$4"\",\"foreign\":\""$5"\",\"state\":\""$6"\",\"program\":\""$7"\"}" }' \
        | tr '\n' ',' | sed 's/,$//')

echo "[$RESULT]"

exit 0
