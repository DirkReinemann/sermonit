#!/bin/bash

# dependencies: awk, echo, grep, ip, sed, tr

set -e
set -o pipefail

class()
{
    local netmask=$1
    case $((netmask/8)) in
        1) echo "A";;
        2) echo "B";;
        3) echo "C";;
        *) echo ""
    esac
}

result=$(
    IFS=$'\n'
    for line in $(ip addr show | awk '/^ / { printf " "$0""; next }; NR>1 { print }; { printf ""$0"" }; END { print }'); do
        name=$(echo "$line" | awk -F': ' '{ print $2 }')
        ether=$(echo "$line" | grep -oE 'link/[a-z]* ([0-9a-f]{2}:){5}[0-9a-f]{2}' | awk '{ print $2 }')
        ip=$(echo "$line" | grep -oE 'inet ([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}' | awk '{ print $2 }')
        ipv4=$(echo "$ip" | awk -F"/" '{ print $1 }')
        netmask=$(echo "$ip" | awk -F"/" '{ print $2 }')
        class=$(class $netmask)
        broadcast=$(echo "$line" | grep -oE 'brd ([0-9]{1,3}\.){3}[0-9]{1,3}' | awk '{ print $2 }')
        ipv6=$(echo "$line" | grep -oE 'inet6 [a-f0-9:]*' | awk '{ print $2 }')
        echo "{\"name\":\"$name\",\"ether\":\"$ether\",\"ipv4\":\"$ipv4\",\"netmask\":\"$netmask\",\"broadcast\":\"$broadcast\",\"class\":\"$class\",\"ipv6\":\"$ipv6\"}"
    done | tr '\n' ',' | sed 's/,$//'
)

echo "[$result]"

exit 0
