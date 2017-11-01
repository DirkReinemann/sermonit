#!/bin/bash

# applications: awk, echo, free, grep, sed, tr

set -e
set -o pipefail

RESULT=$(free -m | grep -v '^-' \
        | awk 'NR>1{ sub(/:/, "", $1); print "{\"type\":\""$1"\",\"total\":\""$2"\",\"used\":\""$3"\",\"free\":\""$4"\"}" }' \
        | tr '\n' ',' | sed 's/,$//')

echo "[$RESULT]"

exit 0
