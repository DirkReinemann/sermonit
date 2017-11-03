#!/bin/bash

# dependencies: echo, grep, rustc

set -e
set -o pipefail

result=$(rustc --version | grep -o [0-9.]*)

echo "\"rust\":\"$result\""

exit 0
