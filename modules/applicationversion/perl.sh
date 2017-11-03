#!/bin/bash

# dependencies: echo, grep, perl

set -e
set -o pipefail

result=$(perl --version | grep -o '(v[0-9.]*)' | grep -o '[0-9.]*')

echo "\"perl\":\"$result\""

exit 0
