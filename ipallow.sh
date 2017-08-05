#!/bin/bash
#This script will add an IP to the allow list in site's .htaccess

ip="$1"
htaccess="$2"

if [ -f "$htaccess" ]; then
	chattr -ia $htaccess
	echo "allow from $ip" >> $PATH
	chmod 644 $htaccess
	chattr +ia $htaccess
	echo "IP: $ip has been allowed access."

else
	echo "File does not exist!"
fi

 