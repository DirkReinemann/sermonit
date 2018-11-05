#!/bin/bash

# dependencies: apachectl, awk, cd, cp, date, echo, grep, gunzip, mkdir, rm, sed, sort, tr, uniq, xargs

set -e
set -o pipefail

logdir=$(apachectl -S 2>/dev/null | grep 'Main ErrorLog' | awk -vFS=": " '{ print $2 }' | sed 's/"//g' | xargs dirname)
tmpdir="/tmp/apacheaccess"
days=10

if [ -d $tmpdir ]; then
    rm -rf $tmpdir
fi

if [ -d $logdir ] && [ $(ls -1 $logdir | wc -l) -gt 0 ]; then
    cp -r $logdir $tmpdir
else
    echo "[]"
    exit 0
fi

cd $tmpdir

for file in $(ls -1); do
    if [ "${file##*.}" == "gz" ]; then
        gunzip $file
    fi
done

IFS=$'\n'
result=$(
    for log in $(grep -Eho '[0-9]{2}/[A-Za-z]{3}/[0-9]{4}' * | sort | uniq -c | tail -$days); do
        day=$(echo "$log" | awk '{ print $2 }')
        sum=$(echo "$log" | awk '{ print $1 }')
        day=$(echo "$day" | sed 's,/, ,g')
        day=$(date -d "$day" +%Y-%m-%d)
        echo "$day $sum"
    done | sort -k1 | awk '{ print "{\"date\":\""$1"\",\"requests\":"$2"}" }' | tr '\n' ','  | sed 's/,$//'
)

rm -rf $tmpdir

echo "[$result]"

exit 0
