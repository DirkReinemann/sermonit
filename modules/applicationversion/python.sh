#!/bin/bash

# dependencies: echo, grep, python

set -e
set -o pipefail

result=$(python 2>&1 --version | grep -o [0-9.]*)

echo "\"python\":\"$result\""

exit 0
