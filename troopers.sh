#!/bin/bash

## Defaults ##
prefix="$(dirname "$0")/"          # prefix should be with "/" in the end
selected_enemy=1                # if you want fight with specific avatar
friend="roushet"

## Reading config file ##
# /!\ Security Warning /!\
# This will execute any command present in the .cfg file
source ${prefix}troopers.cfg

## Reading CLI Args ##
login="$1"                        # 1st argument of cli
password="$2"                     # 2nd argument of cli
[[ -n "$3" ]] && friend="$3"

## Script locals ##
curl_opt="-s -b ${prefix}cookie.$login -c ${prefix}cookie.$login"
exit_cycle=0


## Culture Specific ##
ext=${4:-com}
Another="Another"
Shortage="Shortage"

## Reading culture file ##
# /!\ Security Warning /!\
# This will execute any command present in the .culture file
source ${prefix}${ext}.culture



# Check for "raids"
function check {
    message=`egrep "($Another|$Shortage)" ${prefix}index`
    if [ "$message" == "$Shortage" ] || [ -z "$message" ]
    then
        exit_cycle=1
        mission
    fi
}

# Get money
function getmoney {
    money=`grep money ${prefix}index -A1|tail -n1`
    echo "$login has earned $money coins"
}

# Make 3 "mission" tasks
function mission {
    mission_key=`egrep -o -e "chk=[A-Za-z0-9]{6}" ${prefix}index |tail -n1`
    for i in {1..3}
    do
        curl $curl_opt http://$login.minitroopers.$ext/b/mission?$mission_key
    done
    fight
}

# Make "fight" tasks
function fight {
    for i in {1..3}
    do
        curl $curl_opt http://$login.minitroopers.$ext/b/opp > ${prefix}opp
        fight_key=`egrep -o -e "opp=[0-9]{5,7};chk=[a-zA-Z0-9]{6}" ${prefix}opp|head -n1`
        if [ $selected_enemy -ne 1 ]
        then
            curl $curl_opt http://$login.minitroopers.$ext/b/battle?$fight_key
        else
            curl $curl_opt "http://$login.minitroopers.$ext/b/battle?$fight_key&friend=$friend"
        fi
    done
}

# Login
if [ $# -gt 1 ]
then
    curl $curl_opt -d "login=$login&pass=$password" http://$login.minitroopers.$ext/login
else
    curl $curl_opt -d "login=$login" http://$login.minitroopers.$ext/login
fi
curl $curl_opt http://$login.minitroopers.$ext/hq > ${prefix}index
check

# Make raid tasks
while [ "$exit_cycle" != "1" ]
do
    key=`egrep -o -e "chk=[A-Za-z0-9]{6}" ${prefix}index |tail -n1`
    curl $curl_opt http://$login.minitroopers.$ext/b/raid?$key
    curl $curl_opt http://$login.minitroopers.$ext/hq > ${prefix}index
    check
done

rm -f ${prefix}index ${prefix}opp ${prefix}cookie.*
exit 0
