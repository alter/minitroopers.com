#!/bin/bash

prefix="`dirname $0`/"          # prefix should be with "/" in the end
login=$1                        # 1st argument of cli
password=$2                     # 2nd argument of cli
curl_opt="-s -b ${prefix}cookie.$login -c ${prefix}cookie.$login"
exit_cycle=0
friend=$3

# Check for "raids"
function check {
    message=`egrep "(Another|Shortage)" ${prefix}index`
    if [ "$message" == "Shortage" ] || [ -z "$message" ]
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
        curl $curl_opt http://$login.minitroopers.com/b/mission?$mission_key
    done
    fight
}

# Make "fight" tasks
function fight {
    for i in {1..3}
    do
        curl $curl_opt http://$login.minitroopers.com/b/opp > ${prefix}opp
        chk=`egrep -o -e "chk=[a-zA-Z0-9]{6}" ${prefix}opp|head -n1`
        if [[ -z "$friend" ]]
        then
            opp=`egrep -o -e "opp=[0-9]{5,7}" ${prefix}opp|head -n1`
            curl $curl_opt "http://$login.minitroopers.com/b/battle?$opp;$chk"
        else
            curl $curl_opt --data="chk=$chk&friend=$friend" "http://$login.minitroopers.com/b/battle"
        fi
    done
}

# Login
if [[ -n $password ]]
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

rm -f ${prefix}index ${prefix}opp ${prefix}cookie.*
exit 0
