#!/bin/sh

IPs=($(cat srcIP.txt))
sleep_cycle=$(($(cat sleep_cycle.txt)))
 
count=${#IPs[*]}
i=0

if ip route | grep "default";then
	option=$(ip route | grep "default")		
	option=$(ip route | grep "default")
	option=${option%src*}
else
	echo "Can not change ip ,stop."
	exit 1
fi


if (( $sleep_cycle <= 0 ))
then
	sleep_cycle=20
fi

while (( 1 ))
do
	IP=${IPs[$i]}
	#echo now ip is $IP
	ip route change $option src $IP
	#echo sleep $sleep_cycle
	sleep $sleep_cycle
	i=$(($i+1))
	i=$(($i%$count))		
done
