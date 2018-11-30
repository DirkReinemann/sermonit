#!/bin/bash

# dependencies: awk, echo, head, ps, sed, tr

set -e
set -o pipefail

result=$(ps -eo pmem,pid,euser,egroup,etime,command --sort -pmem | head -11 \
    | awk 'NR>1{ out=""; for(i=6;i<=NF;i++){ out=out" "$i }; sub(/^ /, "", out); gsub(/"/, "", out); gsub(/\\/, "", out); print "{\"memory\":\""$1"\",\"pid\":\""$2"\",\"uid\":\""$3"\",\"gid\":\""$4"\",\"time\":\""$5"\",\"command\":\""out"\"}" }' \
    | tr '\n' ',' | sed 's/,$//'
)

echo "[$result]"

exit 0
