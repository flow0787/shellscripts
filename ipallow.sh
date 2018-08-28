#!/bin/bash
# Description     : This script will add an IP to the allow list in site's .htaccess
# Usage           : ./ipallow.sh $ip $.htaccess
#---------------------------------------------------------------------------------#
# Author		  : Florin Badea
# Source		  : https://github.com/flow0787/shellscripts
#---------------------------------------------------------------------------------#
# Date            : sometime in 2017
# Updated         : 03-08-2018
# Requirements    : SHELL + root for chattr access
# References      : N/A
#=================================================================================#

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

 