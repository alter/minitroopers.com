#!/bin/bash

trap "cleanup" EXIT

login=$1                        # 1st argument of cli
password=$2                     # 2nd argument of cli
friend=$3
site="http://$login.minitroopers.com"
cookie_file="$(mktemp -t "$login.XXXXXX" --suffix='.cookie')"
curl="curl --silent --cookie "$cookie_file""
egrep="grep --extended-regexp --only-matching"

# Check for "raids"
function hasRecruits {
    $curl "$site/hq" | grep "Another" > /dev/null
    return $?
}

# Make 3 "mission" tasks
function mission {
    for i in {1..3}
    do
        $curl "$site/b/mission?chk=$chk"
    done
}

function getCheck {
    local key="$($egrep --regexp='keyy6:[A-Za-z0-9]{6}y[0-9]:' $1)"
    echo ${key:6:6}
}

function getFightKey {
    $curl --cookie-jar "$cookie_file" "$site/b/opp" \
        | $egrep --regexp='opp=[0-9]{5,7};chk=[A-Za-z0-9]{6}' \
        | head --lines=1
}

function fightRandom {
    for i in {1..3}; do
        local key="$(getFightKey)"
        $curl "$site/b/battle?$key"
    done
}

function fightFriend {
    for i in {1..3}; do
        $curl "$site/b/battle?chk=$chk&friend=$1"
    done
}

function raid {
    while hasRecruits
    do
        $curl "$site/b/raid?chk=$chk"
    done
}

function cleanup {
    rm --force "$cookie_file"
}

function login {
    curl --silent --cookie-jar "$cookie_file" --data "$1" "$site/login"
}

# Login
if [[ -n $password ]]
then
    login "login=$login&pass=$password"
else
    login "login=$login"
fi

chk="$(getCheck "$cookie_file")"

# Battle
if [[ -z "$friend" ]]; then
    fightRandom
else
    fightFriend "$friend"
fi &

mission &

raid &

wait

exit 0
