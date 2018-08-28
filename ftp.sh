#!/bin/bash
# Description     : This automates the process of transferring a site's files and folders via FTP
# Usage           : ./ftp.sh
#---------------------------------------------------------------------------------#
# Author		  : Florin Badea
# Source		  : https://github.com/flow0787/shellscripts
#---------------------------------------------------------------------------------#
# Date            : sometime in 2017
# Updated         : 28-08-2018
# Requirements    : SHELL + WGET
# References      : N/A
#=================================================================================#

#Clear the screen and define colors
clear;
BLUE='\033[0;34m'
DARK_RED='\033[1;31m'
NC='\033[0m' 
GREEN='\033[0;32m'


echo -e "${BLUE}-=====BEGIN FTP SITE TRANSFER=====-${NC}"


#Test if transfer folder exists and start downloading
if [ ! -d transfer ]; then
	mkdir transfer; cd transfer;
	read -p "FTP user: " ftp_user;
	read -p "FTP pass: " ftp_pass;
	read -p "FTP host (IP/PATH): " ftp_host;
	echo "-=====  END CREDENTIALS   =====-"
	echo
	wget -mb --passive-ftp --ftp-user=$ftp_user --ftp-password=$ftp_pass ftp://$ftp_host
else
	echo -e "${DARK_RED}transfer directory already exists:${NC}"
	ls -lah transfer
fi

#Wait 3 seconds
sleep 3;

#Check if download went well
if grep -q saved wget-log ; then
	echo
	echo -e "${GREEN}Transfer is now in progress:${NC}"
	grep saved wget-log | tail -5
	echo "-=====END FTP SITE TRANSFER=====-"
else
	echo
	echo -e "${DARK_RED}Issued detected:${NC}"
	echo
	tail -50 wget-log
	echo "-=====END FTP SITE TRANSFER=====-"
fi

echo -e "${BLUE}Check progress by running:${NC}"
echo "tail ~/transfer/wget-log"
echo -e "${GREEN}\t\t-=====Next Steps=====- ${NC}
1. Transfer Database (can use https://www.adminer.org/ if no control panel access)
2. Move site files & folders / Add domain on the account (if needed)
3. Import Database & adjust database connection files"
