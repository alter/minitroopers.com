#!/bin/bash

prefix="`dirname $0`/"          # prefix should be with "/" in the end
login=$1                        # 1st argument of cli
password=$2                     # 2nd argument of cli
curl_opt="-s -b ${prefix}cookie.$login -c ${prefix}cookie.$login"
exit_cycle=0
selected_enemy=1                # if you want fight with specific avatar
friend=$3
if [ -z "$friend" ]
then
  friend="roushet"             # avatar's name
fi

# Check for "raids"
function check {
    message=`egrep "(Another|Shortage)" ${prefix}index`
    if [ "$message" == "Shortage" ] || [ -z "$message" ]
    then
        exit_cycle=1
        mission
    fi
}

# Get the Money/Upgrade cost ratio of the first trooper
function getMoneyRatio {
    local trooper_description="${prefix}${login}.trooper.0.html"
    curl $curl_opt http://$login.minitroopers.com/t/0 > $trooper_description
    local values_array=( $(egrep -e "^[0-9]+$" $trooper_description))
    echo "$login's money for next upgrade : ${values_array[0]}/${values_array[1]}"
}

# Make 3 "mission" tasks
function mission {
    mission_key=`egrep -o -e "chk=[A-Za-z0-9]{6}" ${prefix}index |tail -n1`
    for i in {1..3}
    do
        curl $curl_opt http://$login.minitroopers.com/b/mission?$mission_key
    done
    fight
}

# Make "fight" tasks
function fight {
    for i in {1..3}
    do
        curl $curl_opt http://$login.minitroopers.com/b/opp > ${prefix}opp
        fight_key=`egrep -o -e "opp=[0-9]{5,7};chk=[a-zA-Z0-9]{6}" ${prefix}opp|head -n1`
        if [ $selected_enemy -ne 1 ]
        then
            curl $curl_opt http://$login.minitroopers.com/b/battle?$fight_key
        else
            curl $curl_opt "http://$login.minitroopers.com/b/battle?$fight_key&friend=$friend"
        fi
    done
}

# Login
if [ $# -gt 1 ]
then
    curl $curl_opt -d "login=$login&pass=$password" http://$login.minitroopers.com/login
else
    curl $curl_opt -d "login=$login" http://$login.minitroopers.com/login
fi
curl $curl_opt http://$login.minitroopers.com/hq > ${prefix}index
check

# Make raid tasks
while [ "$exit_cycle" != "1" ]
do
    key=`egrep -o -e "chk=[A-Za-z0-9]{6}" ${prefix}index |tail -n1`
    curl $curl_opt http://$login.minitroopers.com/b/raid?$key
    curl $curl_opt http://$login.minitroopers.com/hq > ${prefix}index
    check
done

getMoneyRatio

rm -f ${prefix}index ${prefix}opp ${prefix}cookie.* ${login}.*
exit 0
