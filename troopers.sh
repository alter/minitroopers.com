#!/bin/bash


### FUNCTIONS ###
# Feel free to skip right down to VARIABLES to do some tweaking


# Greps the amounts of money from the page of the specified trooper.
# Basically, the current amount of money, and the amount needed
# to upgrade
function grepTrooper {
    $curl "$site/t/$1" \
        | $egrep --regexp='^[0-9]+$'
}

# Get the Money/Upgrade cost ratio of the first trooper
function getMoneyRatio {
	local ratio=($(grepTrooper 0))
	local money="${ratio[0]}"
	local upgrade_cost="${ratio[1]}"

    if [[ "$report" == "always" || \
        ( "$report" == "upgradable" && \
          "$money" -ge "$upgrade_cost" ) ]]; then
        echo "$login's money for next upgrade : $money/$upgrade_cost"
    fi
}

# Make 3 "mission" tasks
function mission {
    for i in {1..3}
    do
        $curl "'$site/b/mission?chk=$chk'"
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
        $curl "'$site/b/battle?$key'"
    done
}

function fightFriend {
    for i in {1..3}; do
        $curl "'$site/b/battle?chk=$chk&friend=$1'"
    done
}

# Check for "raids"
function hasRecruits {
    $curl "'$site/hq'" | grep "$Another" > /dev/null
    return $?
}

function raid {
    while hasRecruits
    do
        $curl "'$site/b/raid?chk=$chk'"
    done
}

function login {
    curl --silent --cookie-jar "$cookie_file" --data "$1" "$site/login"
}

function cleanup {
    rm --force "$cookie_file"
}

trap "cleanup" EXIT



### VARIABLES ###



## Defaults ##
prefix="$(dirname "$0")"
ext="com"
Another="Another"
report="upgradable"            # (never|upgradable|always)

## Reading config files ##
# /!\ Security Warning /!\
# `source` will execute any command present in the file
source $prefix/troopers.cfg
source $prefix/$ext.culture

## Reading CLI ##
login=$1                        # 1st argument of cli
password=$2                     # 2nd argument of cli
[[ -n "$3" ]] && friend="$3"

## Script Locals ##
site="http://$login.minitroopers.$ext"
cookie_file="$(mktemp -t "$login.XXXXXX" --suffix='.cookie')"
curl="curl --silent --cookie $cookie_file"
egrep="grep --extended-regexp --only-matching"




## Dependency checks ##
for command in 'grep' 'curl'; do
	which "$command" > /dev/null
	if [[ $? -gt 0 ]]; then
		echo "error: $0 needs $command to execute"
		exit 2
	fi
done


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

if [[ "$report" != "never" ]]; then
    getMoneyRatio
fi

exit 0
