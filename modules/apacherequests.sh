#!/bin/bash

# applications: apachectl, awk, date, echo, grep, wc

set -e
set -o pipefail

APACHE_LOGS=$(apachectl -S | grep 'Main ErrorLog' | awk -vFS=": " '{ print $2 }' | sed 's/"//g' | xargs dirname)
APACHE_DATE=$(date "+%d/%b/%Y:%H:%M:%S")

RESULT=$( (grep -r $APACHE_DATE $APACHE_LOGS/* || printf "") | wc -l | awk '{ print "{\"type\":\"total\",\"requests\":\""$1"\"}" }')

echo "[$RESULT]"

exit 0
