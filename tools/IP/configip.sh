#!/bin/sh

IPs=($(cat srcIP.txt))
count=${#IPs[*]}
dftIP=${IPs[0]}

i=1

rm -f /etc/sysconfig/network-scripts/ifcfg-eth0:*
while (( $i < $count ))
do
	IP=${IPs[$i]}
	sed -e "s/eth0/eth0:$i/;s/$dftIP/$IP/"  /etc/sysconfig/network-scripts/ifcfg-eth0 >  "/etc/sysconfig/network-scripts/ifcfg-eth0:$i"
	i=$(($i+1))
done
