#!/bin/bash

# applications: echo, jq, sed, tr

set -e
set -o pipefail

WORKDIR=$(pwd)
if [ -d "/usr/share/watchit" ]; then
    WORKDIR="/usr/share/watchit"
fi

APPLICATIONSDIR="$WORKDIR/modules/applicationversion"
CONFIGFILE="$WORKDIR/conf/modules/applicationversion.json"

RESULT=$(for A in $(cat $CONFIGFILE | jq .[] | sed 's/"//g'); do
    echo "$(. $APPLICATIONSDIR/$A.sh)"
done | tr '\n' ',' | sed 's/,$//')

echo "{$RESULT}"
