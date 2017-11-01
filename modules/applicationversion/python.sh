#!/bin/bash

# applications: echo, grep, python

set -e
set -o pipefail

RESULT=$(python 2>&1 --version | grep -o [0-9.]*)

echo "\"python\":\"$RESULT\""

exit 0
