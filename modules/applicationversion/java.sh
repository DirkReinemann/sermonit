#!/bin/bash

# dependencies: echo, grep, head, java

set -e
set -o pipefail

jdk=$(java -version 2>&1 | head -1 | grep -o '[0-9._]*')
jvm=$(java -version 2>&1 | tail -1 | grep -o '.*(' | sed 's/ ($//')

echo "\"java\":\"$jvm $jdk\""

exit 0
