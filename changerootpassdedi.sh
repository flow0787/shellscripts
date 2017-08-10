#!/bin/bash
#Script to change root password with a backup of shadow file#
#And reverting changes, after the password update#

clear;
NC='\033[0m' 
GREEN='\033[0;32m'
BOLD_WHITE='\033[1;37m'
RED='\033[0;31m'

#backup_shadow=shadow.Jul-27-2017.Time_02.51.18_PM

function backup() {
	backup_shadow=shadow.`date +"%b-%d-%Y.Time_%I.%M.%S_%p"`;
	cp /etc/shadow /etc/$backup_shadow;
}



new_pass=$(date | md5sum | awk {'print $1'})
echo  -e "=======================================================\n"
echo -e "     NEW PASSWORD: "${GREEN}$new_pass${NC} "\n"

backup

old_pass=$(grep -w root /etc/$backup_shadow)

echo "======================================================="
echo -e "${BOLD_WHITE}BACKUP SHADOW:${NC} "$backup_shadow
echo "======================================================="

echo $new_pass | passwd root --stdin | grep passwd;
echo ""

new_pass_afterchange=$(grep -w root /etc/shadow)


function revert_changes() {
	sed -i "s~$new_pass_afterchange~$old_pass~g" /etc/shadow
}

#while true
#do
#	read -p "Revert changes? [y/n]" answer
#	if [ $answer = "y" ] || [ $answer = "Y" ]; then
#		revert_changes
#		echo -e "${GREEN}Password change reverted!${NC}"
#		break;
#	elif [ $answer = "n" ] || [ $answer = "N" ]; then
#		echo -e "${RED}Changes NOT reverted!${NC}"
#		break;
#	else
#		read -rp "Please enter a valid option! [y/n]"
#	fi
#done

read -n 1 -s -r -p "Press any key to revert root password change."

while true
do
	revert_changes
	echo
	echo -e "${GREEN}Password change reverted!${NC}"
	echo
	break
done
