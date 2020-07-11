#!/bin/bash

LOCK=/tmp/monitoring.lock
if [ -f $LOCK ];then 
	echo "Script is already running"
	exit 6
fi
touch $LOCK
trap 'rm -f "$LOCK"; exit $' INT TERM EXIT

number=$(cat ./str 2>/dev/null);status=$?

checkLines=$(wc ./access-4560-644067.log | awk '{print $1}')

if ! [ -n "$number" ]
then
    timeHead=$(awk '{print $4 $5}' access-4560-644067.log | sed 's/\[//; s/\]//' | sed -n 1p)
    timeLast=$(awk '{print $4 $5}' access-4560-644067.log | sed 's/\[//; s/\]//' | sed -n "$checkLines"p)
    echo $checkLines > ./str
    # Определение количества IP запросов с IP адресов
    IP=$(awk "NR>$checkLines"  access-4560-644067.log | awk '{print $1}' | sort | uniq -c | sort -rn | awk '{ if ( $1 >= 0 ) { print "Количество запросов:" $1, "IP:" $2 } }')
    # Y количества адресов
    addresses=$(awk '($9 ~ /200/)' access-4560-644067.log|awk '{print $7}'|sort|uniq -c|sort -rn|awk '{ if ( $1 >= 10 ) { print "Количество запросов:" $1, "URL:" $2 } }')
    # Все ошибки c момента последнего запуска
    errors=$(cat access-4560-644067.log | cut -d '"' -f3 | cut -d ' ' -f2 | sort | uniq -c | sort -rn)
    echo -e "Данные за период:$timeHead-$timeLast\n$IP\n\n"Часто запрашиваемые адреса:"\n$addresses\n\n"Частые ошибки:"\n$errors" | mail -s "NGINX Log Info" root@localhost
else
    timeHead=$(awk '{print $4 $5}' access-4560-644067.log | sed 's/\[//; s/\]//' | sed -n "$(($number+1))"p)
    timeLast=$(awk '{print $4 $5}' access-4560-644067.log | sed 's/\[//; s/\]//' | sed -n "$checkLines"p)
    IP=$(awk "NR>$(($number+1))"  access-4560-644067.log | awk '{print $1}' | sort | uniq -c | sort -rn | awk '{ if ( $1 >= 0 ) { print "Количество запросов:" $1, "IP:" $2 } }')
    addresses=$(awk '($9 ~ /200/)' access-4560-644067.log|awk '{print $7}'|sort|uniq -c|sort -rn|awk '{ if ( $1 >= 10 ) { print "Количество запросов:" $1, "URL:" $2 } }')
    errors=$(cat access-4560-644067.log | cut -d '"' -f3 | cut -d ' ' -f2 | sort | uniq -c | sort -rn)
    echo $checkLines > ./str
    echo -e "Данные за период:$timeHead-$timeLast\n$IP\n\n"Часто запрашиваемые адреса:"\n$addresses\n\n"Частые ошибки:"\n$errors" | mail -s "NGINX Log Info" walkermr@yandex.ru
fi
rm -f $LOCK
# Снятие трапа
trap - INT TERM EXIT 
