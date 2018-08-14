#!/bin/bash
#description     : This script automates the internal account migrations
#author		     : Florin Badea
#date            : 03.08.2018
#usage		     : ./intmig.sh $USER $SERV_SHORTNAME
#requirements    : SHELL
#=============================================================================


#		TO-DO:
#1. add hostname based download URL - done
#2. do script arguments verification/validation - WIP
#3. fix current domain-based download URL - done
#4. fix the rsync generation url to show from source to dest and from dest to source - done
#5. fix disk usage check (if 500MB it sees it above 20 GB and does skiphomedir) - done

#COLORS
GREEN='\033[0;32m'
DARK_BLUE='\033[1;34m'
RED='\033[0;31m'
NC='\033[0m' 


user=$1
destination=$2
disk_usage=$(du -sk /home/$user | awk {'print $1'})
#APROXIMATE TO INTEGER
#disk_usage=$(printf "%.0f" $disk_usage)
primary_domain=$(grep $user /etc/trueuserdomains | cut -d : -f 1)
current_server=$(hostname)


#IF WE HAVE USER AND SERVER AS ARGUMENTS
if [[ "$#" -eq 0 ]]; then

	echo -e "${DARK_BLUE}This script requires 2 arguments (user and server shortname)!${NC}"
	exit 0
elif [[ "$#" -eq 1 ]]; then
	echo -e "${DARK_BLUE}This script requires 2 arguments (user and server shortname)!${NC}"
	exit 0

fi

#IF USER EXISTS ON THE SERVER 
if grep -q $user /etc/trueuserowners; then
#If account's disk usage below 25 GB
	if [[ "$disk_usage" -le 20000000 ]]; then
		echo -e "${GREEN}Disk usage under 20GB, starting pkgacct:${NC}"
		/usr/local/cpanel/bin/cpuwatch 8 /scripts/pkgacct $user;
		chown $user:$user /home/cpmove-$user.tar.gz;
		chmod 644 /home/cpmove-$user.tar.gz;
		mv /home/cpmove-$user.tar.gz /home/$user/public_html;
		echo -en "${DARK_BLUE}Your download URL:${NC} ";
		echo "http://$primary_domain/cpmove-tar.gz"

	#If usage above 25 GB skip the home folder
	else
		echo -e "${RED}Disk usage over 20GB, packaging account without home:${NC}"
		/usr/local/cpanel/bin/cpuwatch 8 /scripts/pkgacct --skiphomedir $user;
		chown $user:$user /home/cpmove-$user.tar.gz;
		chmod 644 /home/cpmove-$user.tar.gz;
		mv /home/cpmove-$user.tar.gz /home/$user/public_html;
		echo -en "${DARK_BLUE}Your download URL:${NC} ";
		echo "http://$primary_domain/cpmove-$user.tar.gz"
		echo -en "${DARK_BLUE}Hostname-based download URL:${NC} "
		echo "http://$current_server/~$user/cpmove-$user.tar.gz"
		echo -e "${GREEN}SHELL ENABLED! Disable SHELL once rsync is done!${NC}";
		chsh -s /bin/bash $user;
		echo -en "${DARK_BLUE}Your rsync command:${NC} ";
		echo "rsync -auHP $user@$destination.hostpapa.com:/home/$user/ /home/$user/"
	fi
	echo -e "${RED}Remember to remove:${NC} /home/$user/public_html/cpmove-$user.tar.gz"
	else
echo -e "${RED}$user DOES NOT EXIST ON THIS SERVER! Aborting...${NC}";
fi
