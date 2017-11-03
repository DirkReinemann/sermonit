#!/bin/bash

# dependencies: echo, go, grep

set -e
set -o pipefail

result=$(go version | grep -o '[0-9]\.[0-9.]*')

echo "\"go\":\"$result\""

exit 0
