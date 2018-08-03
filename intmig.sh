#!/bin/bash
#description     : This script automates the internal account migrations
#author		     : Florin Badea
#date            : 03.08.2018
#usage		     : ./intmig.sh $USER $SERV_SHORTNAME
#requirements    : SHELL
#=============================================================================

#COLORS
GREEN='\033[0;32m'
DARK_BLUE='\033[1;34m'
RED='\033[0;31m'
NC='\033[0m' 


user=$1
destination=$2
disk_usage=$(du -sh /home/$user | awk {'print $1'} | sed 's/G//g'| sed 's/M//g')
primary_domain=$(grep $user /etc/trueuserdomains | cut -d : -f 1)

#IF USER EXISTS ON THE SERVER 
if [[ "$user" == "$(grep $user /etc/trueuserowners | cut -d : -f 1)" ]]; then

	#IF WE HAVE USER AND SERVER AS ARGUMENTS
	if [[ $# -eq 2 ]]; then
	#If account's disk usage below 25 GB
		if [[ $disk_usage -le 25 ]]; then
			echo -e "${GREEN}Disk usage under 25GB, starting pkgacct:${NC}"
			/scripts/pkgacct $user;
			chown $user:$user /home/cpmove-$user.tar.gz;
			chmod 644 $user:$user /home/cpmove-$user.tar.gz;
			mv /home/cpmove-$user.tar.gz /home/$user/public_html;
			echo -en "${DARK_BLUE}Your download URL:${NC} ";
			echo "http://$primary_domain/cpmove-tar.gz"

		#If usage above 25 GB skip the home folder
		else
			echo -e "${RED}Disk usage over 25 GB, packaging account without home:${NC}"
			/scripts/pkgacct --skiphomedir $user;
			chown $user:$user /home/cpmove-$user.tar.gz;
			chmod 644 $user:$user /home/cpmove-$user.tar.gz;
			mv /home/cpmove-$user.tar.gz /home/$user/public_html;
			echo -en "${DARK_BLUE}Your download URL:${NC} ";
			echo "http://$primary_domain/cpmove-tar.gz"
			echo -e "${GREEN}SHELL ENABLED! Disable once rsync is done!${NC}";
			chsh -s /bin/bash $user;
			echo -en "{$DARK_BLUE}Your rsync command:${NC} ";
			echo "rsync -auHP /home/$user $user@$destination.hostpapa.com:/home/$user"
		fi
		read -n 1 -s -r -p "Press any key to remove the cPanel backup..."
		while true
		do
			rm -vf /home/$user/public_html/cpmove-$user.tar.gz
		done
	else
		echo -e "${DARK_BLUE}This script requires 2 arguments (user and server shortname)!${NC}"
	fi

else
	echo -e "${RED}$user DOES NOT EXIST ON THIS SERVER! Aborting...${NC}";
fi