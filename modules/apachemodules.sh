#!/bin/bash

# applications: apachectl, awk, echo, sed, tr

set -e
set -o pipefail

RESULT=$(apachectl -t -D DUMP_MODULES \
        | awk 'NR>1{ sub(/\(/, "", $2); sub(/\)/, "", $2); print "{\"module\":\""$1"\",\"type\":\""$2"\"}" }' \
        | tr '\n' ',' | sed 's/,$//')

echo "[$RESULT]"

exit 0
