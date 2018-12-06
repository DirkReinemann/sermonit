#!/bin/bash

# dependencies: echo, grep, scala

set -e

result="$(scala -version 2>&1 | grep -Eo '([0-9]+\.)+[0-9]+')"

echo "\"scala\":\"$result\""

exit 0
