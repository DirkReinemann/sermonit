#!/bin/bash

# applications: arp, awk, echo, sed, tr

set -e
set -o pipefail

RESULT=$(arp \
        | awk 'NR>1 { print "{\"address\":\""$1"\",""\"type\":\""$2 "\",""\"mac\":\""$3"\",""\"flags\":\""$4"\",""\"iface\":\""$5"\"}" }' \
        | tr '\n' ',' | sed 's/,$//')

echo "[$RESULT]"

exit 0
