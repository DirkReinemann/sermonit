#!/bin/bash

# applications: echo, grep, scala

set -e
set -o pipefail

RESULT=$(scala -version 2>&1 | grep -Eo '([0-9]+\.)+[0-9]+')

echo "\"scala\":\"$RESULT\""

exit 0
