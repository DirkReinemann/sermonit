#!/bin/bash

# applications: awk, cat, echo, sed, tr

set -e
set -o pipefail

RESULT=$(cat /etc/passwd \
        | awk -F":" '{ print "{\"user\":\""$1"\",\"uid\":\""$3"\",\"gid\":\""$4"\",\"home\":\""$6"\",\"shell\":\""$7"\"}" }' \
        | tr '\n' ',' | sed 's/,$//')

echo "[$RESULT]"

exit 0
