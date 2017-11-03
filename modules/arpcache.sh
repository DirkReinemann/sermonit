#!/bin/bash

# dependencies: arp, awk, echo, sed, tr

set -e
set -o pipefail

result=$(arp \
    | awk 'NR>1 { print "{\"address\":\""$1"\",""\"type\":\""$2 "\",""\"mac\":\""$3"\",""\"flags\":\""$4"\",""\"iface\":\""$5"\"}" }' \
    | tr '\n' ',' | sed 's/,$//'
)

echo "[$result]"

exit 0
