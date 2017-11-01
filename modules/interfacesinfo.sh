#!/bin/bash

# applications: awk, echo, grep, ip, sed, tr

set -e
set -o pipefail

class()
{
    NETMASK=$1
    case $((NETMASK/8)) in
        1) echo "A";;
        2) echo "B";;
        3) echo "C";;
        *) echo ""
    esac
}

RESULT=$(
    IFS=$'\n'
    for LINE in $(ip addr show | awk '/^ / { printf " "$0""; next }; NR>1 { print }; { printf ""$0"" }; END { print }'); do
        NAME=$(echo "$LINE" | awk -F': ' '{ print $2 }')
        ETHER=$(echo "$LINE" | grep -oE 'link/[a-z]* ([0-9a-f]{2}:){5}[0-9a-f]{2}' | awk '{ print $2 }')
        IP=$(echo "$LINE" | grep -oE 'inet ([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}' | awk '{ print $2 }')
        IPV4=$(echo "$IP" | awk -F"/" '{ print $1 }')
        NETMASK=$(echo "$IP" | awk -F"/" '{ print $2 }')
        CLASS=$(class $NETMASK)
        BROADCAST=$(echo "$LINE" | grep -oE 'brd ([0-9]{1,3}\.){3}[0-9]{1,3}' | awk '{ print $2 }')
        IPV6=$(echo "$LINE" | grep -oE 'inet6 [a-f0-9:]*' | awk '{ print $2 }')
        echo "{\"name\":\"$NAME\",\"ether\":\"$ETHER\",\"ipv4\":\"$IPV4\",\"netmask\":\"$NETMASK\",\"broadcast\":\"$BROADCAST\",\"class\":\"$CLASS\",\"ipv6\":\"$IPV6\"}"
    done | tr '\n' ',' | sed 's/,$//'
)

echo "[$RESULT]"

exit 0
