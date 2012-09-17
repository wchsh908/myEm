#!/bin/sh

IPs=($(cat srcIP.txt))
sleep_cycle=$(($(cat sleep_cycle.txt)))

#echo $sleep_cycle
count=${#IPs[*]}
i=0

if (( $sleep_cycle <= 0 ))
then
	sleep_cycle=20
fi

while (( 1 ))
do
	IP=${IPs[$i]}
	#echo now ip is $IP
	ip route change default src $IP dev eth0	 
	#echo sleep $sleep_cycle
	sleep $sleep_cycle
	i=$(($i+1))
	i=$(($i%$count))		
done
