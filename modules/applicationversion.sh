#!/bin/bash

# dependencies: echo, jq, sed, tr

set -e
set -o pipefail

workdir="$(pwd)"

if [[ $workdir == *modules ]]; then
    workdir="${workdir%/*}"
fi

if [ -d "/usr/share/watchit" ]; then
    workdir="/usr/share/watchit"
fi

applicationsdir="$workdir/modules/applicationversion"
configfile="$workdir/config/modules/applicationversion.json"

result=$(
    for application in $(cat $configfile | jq .[] | sed 's/"//g'); do
        content="$(. $applicationsdir/${application}.sh)"
        if [ ! -z "$content" ]; then
            echo "$content"
        fi
    done | tr '\n' ',' | sed 's/,$//'
)

echo "{$result}"
