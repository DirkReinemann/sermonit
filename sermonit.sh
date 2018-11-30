#!/bin/bash

workdir="$(pwd)"
if [ -d "/usr/share/sermonit" ]; then
    workdir="/usr/share/sermonit"
fi

logfile="$workdir/modules.log"
if [ -d "/var/log/sermonit" ]; then
    logfile="/var/log/sermonit/modules.log"
fi

modulesdir="$workdir/modules"

usage()
{
    echo "modules helper functions"
    echo
    echo "Usage: $0 [Options]"
    echo
    echo "Options:"
    printf "  %-20s %s\n" "-s" "sort dependencies in bash module files"
    printf "  %-20s %s\n" "-t" "test all modules"
    printf "  %-20s %s\n" "-u" "list bash modules and their unused dependencies"
    printf "  %-20s %s\n" "-i" "list dependencies and their install state"
    printf "  %-20s %s\n" "-a" "generate markdown list with unique bash dependencies"
    printf "  %-20s %s\n" "-m" "generate markdown table with bash modules and their dependencies"
    printf "  %-20s %s\n" "-c" "generate markdown table with c modules and their dependencies"
    printf "  %-20s %s\n" "-z" "create sermonit zip archive"
    exit 1
}

if [ $# -ne 1 ]; then
    usage
fi

rm $logfile > /dev/null 2>&1

millis() {
    echo $(($(date +%s%N)/1000000))
}

repeatchar()
{
    printf "%$1s" | tr " " "$2"
}

markdowncmoduletable()
{
    echo ""
    printf "| %-30s | %-40s |\n" "c module" "dependencies"
    printf "|-%-30s-|-%-40s-|\n" $(repeatchar 30 '-') $(repeatchar 40 '-')
    grep -ro "^// dependencies.*" $modulesdir | sed 's/\/\/ dependencies: //' \
    | awk -F':' '{ gsub(/.*\//, "", $1); printf "| %-30s | %-40s |\n", $1, $2 }'
}

markdownmoduletable()
{
    echo ""
    printf "| %-30s | %-90s |\n" "bash module" "dependencies"
    printf "|-%-30s-|-%-90s-|\n" $(repeatchar 30 '-') $(repeatchar 90 '-')
    grep -ro "^# dependencies.*" $modulesdir | sed 's/# dependencies: //' \
    | awk -F':' '{ gsub(/.*\//, "", $1); printf "| %-30s | %-90s |\n", $1, $2 }'
}

markdownapplicationlist()
{
    echo ""
    grep -ro "^# dependencies.*" $modulesdir | sed 's/# dependencies: //' \
    | awk -F':' '{ print $2 }' | tr "," "\n" | sed 's/^ //' | sort -u | sed 's/^/  * /'
}

testmodules()
{
    printf "%-40s%-15s%-15s%-s\n\n" "SCRIPT" "IS RUNNING" "HAS DATA" "TIME IN SECONDS"
    local file
    for file in $(find $modulesdir -type f | grep -E '.(sh|o)$'); do
        local filename=$(basename $file)
        local t1=$(millis)
        local result=$(exec $file 2> $logfile)
        local exitcode=$?
        local t2=$(millis)

        printf "\e[39m%-40s" "$filename"
        if [ $exitcode -eq 0 ]; then
            printf "\e[32m%-15s" "success"
            if [[ $result =~ ^\[\]$ ]] || [[ $result =~ ^\{\}$ ]] || [[ -z $result ]]; then
                printf "\e[31m%-15s" "failure"
            else
                printf "\e[32m%-15s" "success"
            fi
        else
            printf "\e[31m%-15s\e[39m%-15s" "failure" "skipped"
        fi
        printf "\e[39m%s\n" $(echo "$t1 $t2" | awk '{ time=($2-$1)/1000; printf "%2.4f", time }')
    done
}

sortapplications()
{
    printf "%-40s%s\n\n" "SCRIPT" "STATUS"
    local file
    for file in $(find $modulesdir -type f | grep '.sh$'); do
        local filename=$(basename $file)
        grep '# dependencies' $file | sed 's/# dependencies: //' | tr ', ' '\n' | sed '/^$/d' | sort \
        | awk -vRS="" -vFS="\n" '{ for(i=1;i<=NF;i++){ out=out", "$i"" }; sub(/^, /, "", out); print "# dependencies: "out"" }' \
        | xargs -I '{}' sed -i 's/# dependencies.*/{}/' $file
        if [ $? -eq 0 ]; then
            printf "\e[39m%-40s\e[32msuccess\n" "$filename"
        else
            printf "\e[39m%-40s\e[31mfailure\n" "$filename"
        fi
    done
}

unusedapplications()
{
    printf "%-40s%s\n\n" "SCRIPT" "UNUSED DEPENDENCIES"
    local file
    for file in $(find $modulesdir -type f | grep '.sh$'); do
        local filename=$(basename $file)
        local result=$(for app in $(grep '# dependencies' $file | sed 's/# dependencies: //' | tr ', ' '\n' | sed '/^$/d'); do
                local count=$(grep $app $file | grep -v '# dependencies' | wc -l)
                if [ $count -eq 0 ]; then
                    printf "$app, "
                fi
        done | sed 's/, $/\n/')
        if [ -z $result ]; then
            printf "\e[39m%-40s\e[31m%s\n" "$filename" "no"
        else
            printf "\e[39m%-40s\e[32m%s\n" "$filename" "$result"
        fi
    done
}

isexcluded()
{
    local exclude=( .git .vagrant README.md log Vagrantfile )
    local file=$1
    local result=0
    for excl in "${exclude[@]}"; do
        if [[ $file == *$excl* ]]; then
            result=1
            break
        fi
    done
    echo $result
}

zipproject()
{
    if [ -f sermonit.zip ]; then
        rm sermonit.zip
    fi

    local file
    local result=$(for file in $(find . -type f); do
            file=${file:2}
            if [ $(isexcluded $file) -eq 0 ]; then
                echo $file
            fi
    done | tr '\n' ' ')
    zip -r9 sermonit.zip $result
}

applicationlist()
{
    printf "%-40s%s\n\n" "APPLICATION" "INSTALLED"
    local app
    for app in $(grep -ro "^# dependencies.*" $modulesdir | sed 's/# dependencies: //' \
        | awk -F':' '{ print $2 }' | tr "," "\n" | sed 's/^ //' | sort -u); do
        hash $app >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            printf "\e[39m%-40s\e[32m%s\n" "$app" "SUCCESS"
        else
            printf "\e[39m%-40s\e[31m%s\n" "$app" "FAILURE"
        fi
    done
}

case $1 in
    "-s") sortapplications;;
    "-t") testmodules;;
    "-u") unusedapplications;;
    "-i") applicationlist;;
    "-z") zipproject;;
    "-a") markdownapplicationlist;;
    "-m") markdownmoduletable;;
    "-c") markdowncmoduletable;;
    *) usage
esac

printf "\e[39m\n\nCheck the logfile '$logfile' for more information.\n"

exit 0
