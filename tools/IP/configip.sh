#!/bin/sh

if ip route | grep "default";then
	option=$(ip route | grep "default")		
	option=$(ip route | grep "default")
	option=${option%src*}
else
	echo "Can not change ip ,stop."
	exit 1
fi


IPs=($(cat srcIP.txt))
count=${#IPs[*]}
dftIP=${IPs[0]}

rm -f /etc/sysconfig/network-scripts/ifcfg-eth0:*	

i=1
while (( $i < $count ))
do
	IP=${IPs[$i]}
	sed -e "s/eth0/eth0:$i/;s/$dftIP/$IP/"  /etc/sysconfig/network-scripts/ifcfg-eth0 >  "/etc/sysconfig/network-scripts/ifcfg-eth0:$i"
	i=$(($i+1))
done

ip route change $option src $dftIP
