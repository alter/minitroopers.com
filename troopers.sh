#!/bin/bash

function check {
    message=`egrep "(Another|Shortage)" index`
    if [ "$message" == "Shortage" ]
    then
        return 0
    fi
}

prefix="/home/alter/troopers/" #prefix should be with "/" in the end.
login=$1
password=$2
curl -c ${prefix}cookie.$login -d "login=$login&pass=$password" http://$login.minitroopers.com/login
curl -b ${prefix}cookie.$login http://$login.minitroopers.com/hq > index
check

while [ $message == "Another" ]
do
    key=`egrep -o -e "chk=[A-Za-z0-9]{6}" index |tail -n1`
    curl -b ${prefix}cookie.$login http://$login.minitroopers.com/b/raid?$key
    curl -b ${prefix}cookie.$login http://$login.minitroopers.com/hq > index
#    money=`grep money index -A1|tail -n1`
#    echo "$login has earned $money coins"
    check
done

rm -f index cookie.*
