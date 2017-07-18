#!/bin/bash

trap "cleanup" EXIT

prefix="`dirname $0`/"          # prefix should be with "/" in the end
login=$1                        # 1st argument of cli
password=$2                     # 2nd argument of cli
friend=$3
site="http://$login.minitroopers.com"
cookie_file="$(mktemp -t \"$login.XXXXXX\" --suffix='.cookie')"
curl_opt="-s -b $cookie_file"

# Check for "raids"
function hasRecruits {
    curl $curl_opt "$site/hq" | grep "Another" > /dev/null
    return $?
}

# Make 3 "mission" tasks
function mission {
    for i in {1..3}
    do
        curl $curl_opt "$site/b/mission?$chk"
    done
}

function getFightKey {
    curl $curl_opt "$site/b/opp" \
        | egrep --only-matching --regexp='opp=[0-9]{5,7};chk=[A-Za-z0-9]{6}' \
        | head --lines=1
}

function getCheck {
    curl $curl_opt "$site/hq" \
        | egrep --only-matching --regexp='chk=[A-Za-z0-9]{6}'
        | tail --lines=1
}

function fightRandom {
    for i in {1..3}; do
        local key="$(getFightKey)"
        curl $curl_opt "$site/b/battle?$key"
    done
}

function fightFriend {
    for i in {1..3}; do
        curl $curl_opt "$site/b/battle?$chk&friend=$1"
    done
}

function raid {
    while hasRecruits
    do
        curl $curl_opt "$site/b/raid?$chk"
    done
}

function cleanup {
    rm --force "$cookie_file"
}

# Login
if [[ -n $password ]]
then
    curl -c "$cookie_file" -d "login=$login&pass=$password" "$site/login"
else
    curl -c "$cookie_file" -d "login=$login" "$site/login"
fi

chk="$(getCheck)"

if [[ -z "$friend" ]]; then
    fightRandom
else
    fightFriend "$friend"
fi

mission

raid

exit 0
