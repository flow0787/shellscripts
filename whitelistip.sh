#!/bin/bash
### Adds an IP to ALLOW chain in iptables - /root/admin/sgfirewall ###

if [[ $# -eq 0 ]]; then
    echo "USAGE: $0 $TID IP.IP.IP.IP"
    echo "USAGE: $0 $TID IP.IP.IP.IP/mask"
    exit 0
fi

sgfirewall=/root/admin/sgfirewall
#backup_sgfirewall=$sgfirewall.`date +"%b-%d-%Y.Time_%I.%M.%S_%p"`


if [[ $# -eq 2 ]]; then
	ip=$(iptables -n -L | grep $2 | awk {'print $4'})
	if [ "$2" == "$ip" ]; then
		echo "$2 is already in iptables. Exiting..."
		iptables -n -L | grep $2
	else
		#cp $sgfirewall $backup_sgfirewall 
		#echo "=========================================================================="
		#echo "Backing-up sgfirewall: $backup_sgfirewall"
		#echo "=========================================================================="
		echo >> $sgfirewall
		echo "#TID $1" >> $sgfirewall
		echo "iptables -I in_sg -s $2 -j ACCEPT" >> $sgfirewall
		echo "==================================================================="
		/etc/init.d/firewall restart
		echo "==================================================================="
		echo "IP Address >>>> $2 <<<< whitelisted!"
		grep $2 $sgfirewall
		echo "==================================================================="
	fi
else
	echo "Please add the IP as second argument!"
fi
