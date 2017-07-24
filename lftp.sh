#!/bin/bash
## LFTP/SFTP site transfer script. ##

clear;
CYAN='\033[0;36m'
DARK_RED='\033[1;31m'
NC='\033[0m' 

echo -e "${CYAN}-=====BEGIN LFT/SFTP SITE TRANSFER=====-${NC}"

cd /home/transfer || echo "Could not cd /home/transfer directory."
read -rp "Enter ticket ID: " tid;


if [ ! -d "$tid" ]; then
    mkdir $tid; cd $tid || echo "Could not cd transfer";
    read -rp "sFTP user and sFtp pass: " ftp_user ftp_pass;
    read -rp "sFTP host: " ftp_host;
    read -rp "Site path and new path: " old_path $new_path;
	lftp -u "$ftp_user","$ftp_pass" -e `mirror "$old_path" "$new_path"` sftp://"$ftp_host":22
else
    echo "${DARK_RED}$tid directory already exists:${NC}"
    ls -lah $tid
fi
