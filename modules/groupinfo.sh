#!/bin/bash

# applications: awk, cat, echo, sed, tr

set -e
set -o pipefail

RESULT=$(cat /etc/group | awk -F":" '{ print "{\"group\":\""$1"\",\"gid\":\""$3"\",\"users\":\""$4"\"}" }' \
        | tr '\n' ',' | sed 's/,$//')

echo "[$RESULT]"

exit 0
