#!/bin/bash
#Script to change root password with a backup of shadow file#

clear;
new_pass=$(date | md5sum | awk {'print $1'})
echo -e "=======================================================\n"
echo -e "     NEW PASSWORD: "$new_pass "\n"
backup_shadow=/etc/shadow.`date +"%b-%d-%Y.Time_%I.%M.%S_%p"`;

cp /etc/shadow $backup_shadow;

echo "======================================================="
echo "BACKUP SHADOW: "$backup_shadow
echo "======================================================="

echo $new_pass | passwd root --stdin | grep passwd;
echo ""
