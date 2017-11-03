#!/bin/bash

# dependencies: awk, echo, ruby

set -e
set -o pipefail

result=$(ruby --version | awk '{ print $2 }')

echo "\"ruby\":\"$result\""

exit 0
