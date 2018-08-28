#!/bin/bash
# Description     : This script automates the LFTP/sFTP transfers
# Usage           : ./lftp.sh
#---------------------------------------------------------------------------------#
# Author		  : Florin Badea
# Source		  : https://github.com/flow0787/shellscripts
#---------------------------------------------------------------------------------#
# Date            : sometime in 2017
# Updated         : -
# Requirements    : SHELL + lftp
# References      : N/A
#=================================================================================#

clear;
CYAN='\033[0;36m'
DARK_RED='\033[1;31m'
NC='\033[0m' 


echo -e "${CYAN}-=====BEGIN LFT/SFTP SITE TRANSFER=====-${NC}"

cd /home/transfer || echo "Could not cd /home/transfer directory."
read -rp "Enter ticket ID: " tid;
new_path=/home/transfer/$tid

if [ ! -d "$tid" ]; then
    mkdir $tid; cd $tid || echo "Could not cd transfer";
    read -rp "sFTP user and sFtp pass: " ftp_user ftp_pass;
    read -rp "sFTP host: " ftp_host;
    read -rp "Site path: " old_path;
	lftp -u "$ftp_user","$ftp_pass" -e `mirror "$old_path" "$new_path"` sftp://"$ftp_host":22
else
    echo -e "${DARK_RED}$tid directory already exists:${NC}"
    ls -lah $tid
fi
