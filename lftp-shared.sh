#!/bin/bash
## LFTP/SFTP site transfer script. ##

clear;
CYAN='\033[0;36m'
DARK_RED='\033[1;31m'
NC='\033[0m' 


echo -e "${BLUE}-=====BEGIN FTP SITE TRANSFER=====-${NC}"
$new_path=transfer/

if [ ! -d transfer ]; then
	mkdir transfer; cd transfer;
    read -rp "sFTP user and sFTP pass: " sftp_user sftp_pass;
    read -rp "Remote path: " old_path;
	read -p "sFTP host: " sftp_host;
	echo "-=====  END CREDENTIALS   =====-"
	echo
	lftp -u "$sftp_user","$sftp_pass" -e `mirror "$old_path" "$new_path"` sftp://"$sftp_host":22
else
    echo -e "${DARK_RED}transfer/ directory already exists:${NC}"
    ls -lah transfer/
fi