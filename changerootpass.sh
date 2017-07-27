#!/bin/bash
#Script to change root password with a backup of shadow file#

clear;
NC='\033[0m' 
GREEN='\033[0;32m'
BOLD_WHITE='\033[1;37m'

new_pass=$(date | md5sum | awk {'print $1'})
echo -e "=======================================================\n"
echo -e "     NEW PASSWORD: "${GREEN}$new_pass${NC} "\n"
backup_shadow=/etc/shadow.`date +"%b-%d-%Y.Time_%I.%M.%S_%p"`;

cp /etc/shadow $backup_shadow;

echo "======================================================="
echo -e "${BOLD_WHITE}BACKUP SHADOW:${NC} "$backup_shadow
echo "======================================================="

echo $new_pass | passwd root --stdin | grep passwd;
echo ""
