#!/bin/bash

prefix="/home/alter/troopers/" # prefix should be with "/" in the end
login=$1                       # 1st argument of cli
password=$2                    # 2nd argument of cli

# Check for "raids"
function check {
    message=`egrep "(Another|Shortage)" index`
    if [ "$message" == "Shortage" ]
    then
        mission
    fi
}

# Get money
function getmoney {
    money=`grep money index -A1|tail -n1`
    echo "$login has earned $money coins"
}

# Make 3 "mission" tasks
function mission {
    mission_key=`egrep -o -e "chk=[A-Za-z0-9]{6}" index |tail -n1`
    for i in {1..3}
    do
        curl -b ${prefix}cookie.$login http://$login.minitroopers.com/b/mission?$mission_key
    done
}

# Login
curl -c ${prefix}cookie.$login -d "login=$login&pass=$password" http://$login.minitroopers.com/login
curl -b ${prefix}cookie.$login http://$login.minitroopers.com/hq > index
check

# Make raid tasks
while [ $message == "Another" ]
do
    key=`egrep -o -e "chk=[A-Za-z0-9]{6}" index |tail -n1`
    curl -b ${prefix}cookie.$login http://$login.minitroopers.com/b/raid?$key
    curl -b ${prefix}cookie.$login http://$login.minitroopers.com/hq > index
    check
done

rm -f ./index ./cookie.*
exit 0
