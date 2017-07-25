#!/bin/bash
### Adds an IP to DENY chain in iptables - /root/admin/sgfirewall ###
### WORK IN PROGRES ##

#COLORS
DARK_RED='\033[1;31m'
GREEN='\033[0;32m'
DARK_BLUE='\033[1;34m'
RED='\033[0;31m'
NC='\033[0m' 


sgfirewall=/root/admin/sgfirewall

#verification variables used to test if IP and port exist in iptables
ip=$(iptables -n -L | grep $2 | awk {'print $4'})
port=$(netstat -ant | grep LISTEN | sed -n 's/^[^:]*:\([0-9]\+\) .*$/\1/p'| uniq)


function blacklistip() {
	if [[ $# -eq 2 ]]; then
		if [ "$2" == "$ip" ] || grep -q $2 $sgfirewall ; then
			echo -e "${DARK_RED}>>>> $2 <<<<${NC} ${RED}is already in iptables:${NC}"
			echo -en "${DARK_BLUE}$sgfirewall:${NC} "; grep $2 $sgfirewall
			echo -en "${DARK_BLUE}iptables:${NC} "; iptables -n -L | grep $2
		else
			#backup
			echo "#TID $1" >> $sgfirewall
			echo "iptables -I in_sg -s $2 -j DROP" >> $sgfirewall
			echo "==================================================================="
			/etc/init.d/firewall restart
			echo "==================================================================="
			echo -e "${GREEN}IP >>>> $2 <<<< blacklisted!${NC}"
			echo -en "${DARK_BLUE}$sgfirewall:${NC} "; grep $2 $sgfirewall
			echo -en "${DARK_BLUE}iptables:${NC} "; iptables -n -L | grep $2
			echo "==================================================================="

		fi
	elif [[ $# -eq 3 ]]; then
		if [ "$2" == "$ip" ] || grep -q $2 $sgfirewall && [ "$3" == "$port" ]; then
			echo -e "${DARK_RED}>>>> $2 <<<<${NC} ${RED}is already in iptables:${NC}"
			echo -en "${DARK_BLUE}$sgfirewall:${NC} "; grep $2 $sgfirewall
			echo -en "${DARK_BLUE}iptables:${NC} " ; iptables -n -L | grep $2
		else
			#backup
			echo "#TID $1" >> $sgfirewall
			echo "iptables -I in_sg -p tcp -s $2 --dport $3 -j DROP" >> $sgfirewall
			echo "==================================================================="
			/etc/init.d/firewall restart
			echo "==================================================================="
			echo -e "${GREEN}Port >>>> $3 <<<< on IP >>>> $2 <<<< blocked!${NC}"
			echo -en "${DARK_BLUE}$sgfirewall:${NC} "; grep $2 $sgfirewall
			echo -en "${DARK_BLUE}iptables:${NC} "; iptables -n -L | grep $2
			echo "==================================================================="
		fi
	else
		echo "Please add the IP as second argument!"
		echo "Please add the port as 3rd argument (not required)."
	fi
}

function whitelistip() {
	if [[ $# -eq 2 ]]; then
		if [ "$2" == "$ip" ] || grep -q $2 $sgfirewall ; then
			echo -e "${DARK_RED}>>>> $2 <<<<${NC} ${RED}is already in iptables:${NC}"
			echo -en "${DARK_BLUE}$sgfirewall:${NC} " ; grep $2 $sgfirewall
			echo -en "${DARK_BLUE}iptables:${NC} " ; iptables -n -L | grep $2
		else
		#backup
		echo >> $sgfirewall
		echo "#TID $1" >> $sgfirewall
		echo "iptables -I in_sg -s $2 -j ACCEPT" >> $sgfirewall
		echo "==================================================================="
		/etc/init.d/firewall restart
		echo "==================================================================="
		echo -e "${GREEN}IP >>>> $2 <<<< whitelisted!${NC}"
		echo -en "${DARK_BLUE}$sgfirewall:${NC} " ; grep $2 $sgfirewall
		echo -en "${DARK_BLUE}iptables:${NC} " ; iptables -n -L | grep $2
		echo "==================================================================="
	fi
	elif [[ $# -eq 3 ]]; then
		if [ "$2" == "$ip" ] || grep -q $2 $sgfirewall && [ "$3" == "$port" ]; then
			echo -e "${DARK_RED}>>>> $2 $3 <<<<${NC} ${RED}is already in iptables:${NC}"
			echo -en "${DARK_BLUE}$sgfirewall:${NC} " ; grep $2 $sgfirewall
			echo -en "${DARK_BLUE}iptables:${NC} " ; iptables -n -L | grep $2
		else
			#backup
			echo "#TID $1" >> $sgfirewall
			echo "iptables -I in_sg -p tcp -s $2 --dport $3 -j ACCEPT" >> $sgfirewall
			echo "iptables -I out_sg -p tcp -d $2 --dport $3 -j ACCEPT" >> $sgfirewall
			echo "==================================================================="
			/etc/init.d/firewall restart
			echo "==================================================================="
			echo -e "${GREEN}Port >>>> $3 <<<< on IP >>>> $2 <<<< whitelisted!${NC}"
			echo -en "${DARK_BLUE}$sgfirewall:${NC} " ; grep $2 $sgfirewall
			echo -en "${DARK_BLUE}iptables:${NC} " ; iptables -n -L | grep $2
			echo "==================================================================="
		fi
	else
		echo "Please add the IP as second argument!"
		echo "Please add the port as 3rd argument (not a requirement)."
	fi
}

function backup(){
	backup_sgfirewall=$sgfirewall.`date +"%b-%d-%Y.Time_%I.%M.%S_%p"`
	cp $sgfirewall $backup_sgfirewall 
	echo "=============================================================="
	echo "${GREEN}Backing-up sgfirewall: $backup_sgfirewall${NC}"
	echo "=============================================================="
}

if [[ $# -eq 0 ]]; then
    echo "USAGE: $0 TID IP.IP.IP.IP"
    echo "USAGE: $0 TID IP.IP.IP.IP/mask"
    echo "USAGE: $0 TID IP.IP.IP.IP PORT"
    exit 0
elif [[ $# -eq 1 ]]; then
    echo "Please add the IP as second argument!"
    exit 0
elif [[ $# -eq 2 ]] || [[ $# -eq 3 ]]; then
	#read -p "Whitelist or blacklist? [w/b] " answer
	while true 
	do
		if [[ $answer = "b" ]] || [[ $answer = "B" ]] && [[ $# -eq 2 ]]; then
		    blacklistip $1 $2
		    break
	    elif [[ $answer = "w" ]] || [[ $answer = "W" ]] && [[ $# -eq 2 ]]; then
	        	whitelistip $1 $2
	        	break
	    elif [[ $answer = "b" ]] || [[ $answer = "B" ]] && [[ $# -eq 3 ]]; then
	    	blacklistip $1 $2 $3
	    	break
	    elif [[ $answer = "w" ]] || [[ $answer = "W" ]] && [[ $# -eq 3 ]]; then
	    	whitelistip $1 $2 $3
	    	break

	    fi
	    read -p "Whitelist or blacklist? [w/b] " answer
	done;
else
	echo "USAGE: $0 TID IP.IP.IP.IP"
    echo "USAGE: $0 TID IP.IP.IP.IP/mask"
    echo "USAGE: $0 TID IP.IP.IP.IP PORT"
fi
