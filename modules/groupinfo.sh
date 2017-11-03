#!/bin/bash

# dependencies: awk, cat, echo, sed, tr

set -e
set -o pipefail

result=$(cat /etc/group | awk -F":" '{ print "{\"group\":\""$1"\",\"gid\":\""$3"\",\"users\":\""$4"\"}" }' \
    | tr '\n' ',' | sed 's/,$//'
)

echo "[$result]"

exit 0
