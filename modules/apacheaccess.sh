#!/bin/bash

# applications: apachectl, awk, cd, cp, date, echo, grep, gunzip, mkdir, rm, sed, sort, tr, uniq, xargs

set -e
set -o pipefail

LOGDIR=$(apachectl -S | grep 'Main ErrorLog' | awk -vFS=": " '{ print $2 }' | sed 's/"//g' | xargs dirname)
TMPDIR="/tmp/apacheaccess"

if [ -d $TMPDIR ]; then
	rm -rf $TMPDIR
fi

mkdir -p $TMPDIR

cp -r $LOGDIR/* $TMPDIR

cd $TMPDIR

for F in $(ls -1); do
	if [ "${F##*.}" == "gz" ]; then
		gunzip $F
	fi
done

IFS=$'\n'
RESULT=$(
	for I in $(grep -Eho '[0-9]{2}/[A-Za-z]{3}/[0-9]{4}' * | sort | uniq -c); do
		DAY=$(echo "$I" | awk '{ print $2 }')
		SUM=$(echo "$I" | awk '{ print $1 }')

		DAY=$(echo "$DAY" | sed 's,/, ,g')
		DAY=$(date -d "$DAY" +%Y-%m-%d)
		echo "$DAY $SUM"
	done | sort -k1 | awk '{ print "{\"date\":\""$1"\",\"requests\":"$2"}" }' | tr '\n' ','  | sed 's/,$//'
)

rm -rf $TMPDIR

echo "[$RESULT]"

exit 0
