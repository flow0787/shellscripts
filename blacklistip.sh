#!/bin/bash
# Description     : A shell script that adds an IP or range to DENY chain in iptables
#				    /root/admin/sgfirewall
# Usage           : ./blacklistip.sh $ip
#				  : ./blacklistip.sh $ip/mask 
#---------------------------------------------------------------------------------#
# Author		  : Florin Badea
# Source		  : https://github.com/flow0787/shellscripts
#---------------------------------------------------------------------------------#
# Date            : sometime in 2017
# Requirements    : SHELL + iptables
# References      : N/A
#=================================================================================#

#Input verification && Usage information
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
		#echo "=============================================================="
		#echo "Backing-up sgfirewall: $backup_sgfirewall"
		#echo "=============================================================="
		echo "#TID $1" >> $sgfirewall
		echo "iptables -I in_sg -s $2 -j DENY" >> $sgfirewall
		/etc/init.d/firewall restart
		echo "IP Address >>>> $2 <<<< blacklisted!"
		grep $2 $sgfirewall
	fi
else
	echo "Please add the IP as second argument!"
fi
