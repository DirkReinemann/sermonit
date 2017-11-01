#!/bin/bash

# applications: echo, grep, head, java

set -e
set -o pipefail

JDK=$(java -version 2>&1 | head -1 | grep -o '[0-9._]*')
JVM=$(java -version 2>&1 | tail -1 | grep -o '.*(' | sed 's/ ($//')

echo "\"java\":\"$JVM $JDK\""

exit 0
