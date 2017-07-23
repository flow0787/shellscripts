#!/bin/bash

#//TODO:
####### - detect browser and flush cache per browser used



#Detecting the OS
platform='unknown'
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
   platform='linux'
elif [[ "$unamestr" == 'Darwin' ]]; then
   platform='mac'
fi



function add_to_hosts(){
	echo
	echo $1 $2 www.$2 >> /etc/hosts
	echo "Added $1 $2 www.$2 to /etc/hosts"

}


function flush_caches(){
	if [ $platform = "linux" ]; then 
		for i in {1..10} 
		do
			/etc/init.d/dns-clean start &>/dev/null;
		done
		echo
		echo "Flushed DNS caches 10 times!"
		rm -rf /home/$(whoami)/.cache/google-chrome
		echo "Flushed Google Chrome caches!"
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
	echo "USAGE: $0 IP DOMAIN"
	exit 0
elif [[ $# -eq 1 ]]; then
	echo "Script requires IP and DOMAIN as arguments."
	exit 0
elif [[ $# -gt 2 ]]; then
	echo "You provided more than 2 arguments."
	exit 0
else
	add_to_hosts $1 $2
	flush_caches
	if [ $platform = "linux" ]; then
		google-chrome $2
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
		echo "Changes NOT reverted"
		break;
	else
		read -rp "Please enter a valid option! [y/n]"
	fi
done
