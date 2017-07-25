#!/bin/bash

#//TODO:
####### - detect browser and flush cache per browser used

RED='\033[0;31m'
DARK_BLUE='\033[1;34m'
BOLD_WHITE='\033[1;37m'
# No Color
NC='\033[0m' 

#Detecting the OS
platform='unknown'
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
   platform='linux'
elif [[ "$unamestr" == 'Darwin' ]]; then
   platform='mac'
fi

domain=$(grep $2 /etc/hosts | cut -d " " -f 2 | sort | uniq)

function add_to_hosts(){
	if [ "$2" == "$domain" ]; then
		echo
		echo -e "${RED}Domain $2 is already in /etc/hosts:${NC}"
		grep $2 /etc/hosts
		echo
		exit 0
	else
		echo
		echo $1 $2 www.$2 >> /etc/hosts
		echo -e "Added ${RED}$1 $2 www.$2${NC} to /etc/hosts"
	fi
}


function flush_caches(){
	if [ $platform = "linux" ]; then 
		for i in {1..10} 
		do
			/etc/init.d/dns-clean start &>/dev/null;
		done
		echo
		echo -e "${DARK_BLUE}Flushed DNS caches 10 times!${NC}"
		rm -rf /home/$(whoami)/.cache/google-chrome
		echo -e "${DARK_BLUE}Flushed Google Chrome caches!${NC}"
		echo
	elif [ $platform = "mac" ]; then
		for i in {1..10} 
		do
			dscacheutil -flushcache;
			killall -HUP mDNSResponder;
		done
		echo
		echo "Flushed DNS caches 10 times!"
		rm -rf /Users/$(whoami)/Library/Caches/Google/Chrome/Default/Cache/ || echo "Could not flush Chrome cache on Mac."
		echo "Flushed Google Chrome caches!"
		echo
	fi

}

if [[ $# -eq 0 ]]; then
	echo -e "${RED}USAGE: $0 IP DOMAIN${NC}"
	exit 0
elif [[ $# -eq 1 ]]; then
	echo -e "${RED}Script requires IP and DOMAIN as arguments.${NC}"
	exit 0
elif [[ $# -gt 2 ]]; then
	echo -e "${RED}You provided more than 2 arguments.${NC}"
	exit 0
else
	add_to_hosts $1 $2
	flush_caches
	if [ $platform = "linux" ]; then
		google-chrome $2 &>/dev/null
	elif [ $platform = "mac" ]; then
		open --new -a /Applications/Google\ Chrome.app --args $2
	fi
fi



read -rp "Revert changes [y/n]? " answer
while true
do
	if [ $answer = "y" ] || [ $answer = "Y" ]; then
		if [ $platform = "linux" ]; then
			sed -i "/$1 $2 www.$2/d" /etc/hosts
			break;
		elif [ $platform = "mac" ]; then
			sed -i "" "s/$1 $2 www.$2//g" /etc/hosts
			break;
		fi
	elif [ $answer = "n" ] || [ $answer = "N" ]; then
		echo -e "${RED}Changes NOT reverted!${NC}"
		break;
	else
		read -rp "Please enter a valid option! [y/n]"
	fi
done
