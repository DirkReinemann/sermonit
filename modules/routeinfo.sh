#!/bin/bash

# dependencies: awk, echo, route, sed, tr

set -e
set -o pipefail

result=$(route -n \
    | awk 'NR>2 { print "{\"destination\":\""$1"\",\"gateway\":\""$2"\",\"genmask\":\""$3"\",\"flags\":\""$4"\",\"iface\":\""$8"\"}" }' \
    | tr '\n' ',' | sed 's/,$//'
)

echo "[$result]"

exit 0
