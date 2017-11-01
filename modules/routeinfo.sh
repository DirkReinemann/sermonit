#!/bin/bash

# applications: awk, echo, route, sed, tr

set -e
set -o pipefail

RESULT=$(route -n \
        | awk 'NR>2 { print "{\"destination\":\""$1"\",\"gateway\":\""$2"\",\"genmask\":\""$3"\",\"flags\":\""$4"\",\"iface\":\""$8"\"}" }' \
        | tr '\n' ',' | sed 's/,$//')

echo "[$RESULT]"

exit 0
