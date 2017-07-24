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
florinba@esm9 [~/public_html/s]# cat changerootpassdedi.sh
clear;
new_pass=$(date | md5sum | awk {'print $1'})
echo -e "=======================================================\n"
echo -e "     NEW PASSWORD: "$new_pass "\n"
backup_shadow=/etc/shadow.`date +"%b-%d-%Y.Time_%I.%M.%S_%p"`;

cp /etc/shadow $backup_shadow;
current_hash=$(grep root $backup_shadow)


echo "======================================================="
echo "BACKUP SHADOW: "$backup_shadow
echo "======================================================="

echo $new_pass | passwd root --stdin | grep passwd;
new_hash=$(grep root /etc/shadow)
echo ""

echo "new_hash: " $new_hash
echo "current_hash: " $current_hash

#read -p "Revert changes [y/n]?" answer;
#REVERT CHANGES BY FILE COPY#
#if [ $answer = "y" ] || [ $answer = "Y" ]
#    then
#        mv /etc/shadow /etc/shadow-ds
#        mv $backup_shadow /etc/shadow
#        echo "root password changes reverted."
#    elif [ $answer = "n" ] || [ $answer = "N" ]
#    then
#        echo "root password NOT reverted.";
#    else
#        echo "Please enter y or n.";
#        read -p "Revert changes [y/n]?" answer;
#fi

#REVERT CHANGES BY SED#
#if [ $answer = "y" ] || [ $answer = "Y" ]
#	then
#		sed -i "s~$new_hash~$current_hash~g" /etc/shadow
#		echo "root password change reverted."		
#fi
