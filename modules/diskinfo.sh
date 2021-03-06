#!/bin/bash

# dependencies: awk, df, echo, grep, sed, tr

set -e
set -o pipefail

result=$(df -h | grep '^/dev' \
    | awk '{ print "{\"filesystem\":\""$1"\",\"size\":\""$2"\",\"used\":\""$3"\",\"available\":\""$4"\",\"use\":\""$5"\",\"mounted\":\""$6"\"}" }' \
    | tr '\n' ',' | sed 's/,$//'
)

echo "[$result]"

exit 0
