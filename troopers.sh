#!/bin/bash

trap "cleanup" EXIT

prefix="`dirname $0`/"          # prefix should be with "/" in the end
login=$1                        # 1st argument of cli
password=$2                     # 2nd argument of cli
curl_opt="-s -b ${prefix}cookie.$login -c ${prefix}cookie.$login"
friend=$3

# Check for "raids"
function hasRecruits {
    curl $curl_opt http://$login.minitroopers.com/hq > ${prefix}index
    local message=`egrep "(Another|Shortage)" ${prefix}index`
    [[ "$message" == "Another" ]]
    return $?
}

# Get money
function getmoney {
    money=`grep money ${prefix}index -A1|tail -n1`
    echo "$login has earned $money coins"
}

# Make 3 "mission" tasks
function mission {
    for i in {1..3}
    do
        curl $curl_opt http://$login.minitroopers.com/b/mission?$chk
    done
}

function getFightKey {
    curl $curl_opt "http://$login.minitroopers.com/b/opp" \
        | egrep --only-matching --regexp='opp=[0-9]{5,7};chk=[A-Za-z0-9]{6}' \
        | head --lines=1
}

function fightRandom {
    for i in {1..3}; do
        local key="$(getFightKey)"
        curl $curl_opt "http://$login.minitroopers.com/b/battle?$key"
    done
}

function fightFriend {
    for i in {1..3}; do
        curl $curl_opt "http://$login.minitroopers.com/b/battle?$chk&friend=$1"
    done
}

function raid {
    while hasRecruits
    do
        curl $curl_opt http://$login.minitroopers.com/b/raid?$chk
    done
}

function cleanup {
    rm -f ${prefix}index ${prefix}cookie.*
}

# Login
if [[ -n $password ]]
then
    curl $curl_opt -d "login=$login&pass=$password" http://$login.minitroopers.com/login
else
    curl $curl_opt -d "login=$login" http://$login.minitroopers.com/login
fi

curl $curl_opt http://$login.minitroopers.com/hq > ${prefix}index
chk=`egrep -o -e "chk=[A-Za-z0-9]{6}" ${prefix}index |tail -n1`

if [[ -z "$friend" ]]; then
    fightRandom
else
    fightFriend $friend
fi

mission

raid

exit 0
