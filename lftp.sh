#!/bin/bash
## LFTP/SFTP site transfer script. ##

clear;
echo "-=====BEGIN LFT/SFTP SITE TRANSFER=====-"

cd /home/transfer || echo "Could not cd /home/transfer directory."
read -rp "Enter ticket ID: " tid;


if [ ! -d "$tid" ]; then
    mkdir $tid; cd $tid || echo "Could not cd transfer";
    read -rp "sFTP user and sFtp pass: " ftp_user ftp_pass;
    read -rp "sFTP host: " ftp_host;
    read -rp "Site path and new path: " old_path $new_path;
	lftp -u "$ftp_user","$ftp_pass" -e `mirror "$old_path" "$new_path"` sftp://"$ftp_host":22
else
    echo "$tid directory already exists:"
    ls -lah $tid
fi
