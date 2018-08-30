#!/bin/bash
# Description     : A shell script to review a cPanel account's traffic information 
#				    and resource usage statistics based on user and days - VERSION 2
# Usage           : ./analyzer_v2.sh $user $days
#---------------------------------------------------------------------------------#
# Author		  : Florin Badea
# Source		  : https://github.com/flow0787/shellscripts
#---------------------------------------------------------------------------------#
# Date            : 26-08-2018
# Requirements    : SHELL + LVEINFO/CloudLinux
# References      : https://stackoverflow.com/questions/7706095/filter-log-file-entries-based-on-date-range
#=================================================================================#

user=$1
days=$2
path=/home/$user/logs
onetothirtyoneregex='^([1-9]|[12][0-9]|3[01])$'
currentmonth=$(date +"%-b")
domainregex='^([a-zA-Z0-9][a-zA-Z0-9-_]*\.)*[a-zA-Z0-9]*[a-zA-Z0-9-_]*[[a-zA-Z0-9]+$'


#Arguments verification check
if [[ $# -eq 0 ]]; then
	echo -e "Please provide a cPanel user ..."
	exit 0
elif [[ $# -gt 2 ]]; then
	echo -e "You provided more than 2 argument! Exitting ..."
	exit 0
elif ! [[ $days =~ $onetothirtyoneregex ]]; then
	echo -e "Days, the second script argument must be one or two digit number up to 31! Exitting ..."
	exit 0
elif [[ $# -eq 1 ]]; then
	echo -e "Days was not provided as an argument. Exitting ...!"
	exit 0
#If days = 1 then change path to access-logs which holds stats for past 24 hrs
elif [[ $days -eq 1 ]]; then
	path=/home/$user/access-logs
elif [[ $1 =~ $domainregex ]]; then
	if grep -q /etc/userdomains; then
		$user=$(/scripts/whoowns $1)
	else
		echo "Domain does not exist on this server! Exitting ..."
		exit 0
	fi
fi
echo ;

#Getting general account information
function general_info(){
	echo " === General Info =============";
	echo -en "username\t: $user \n";
	echo -en "hosting plan\t: " ; grep PLAN /var/cpanel/users/$user | cut -d = -f2
	echo -en "suspended\t: ";
	if [[ -f /var/cpanel/suspended/$user ]]; then 
		if [[ -s /var/cpanel/suspended/$user ]]; then
		cat /var/cpanel/suspended/$user
		else
		echo "Suspended without notes!"
		fi
	else 
		echo "Not Suspended";
	fi 
	echo ;
}

#Getting cron job information
function cron_info(){
	echo " === Cron Job Info ============"; 
	crontab -u $user -l;
	echo ;
}

#Getting CloudLinux limits for the $user
function get_cllimits(){
	echo " === CloudLinux Limits for $user ============";
	lvectl list-user 2> /dev/null | head -1 ; lvectl list-user | grep $user
	echo ;
}

#Getting domain information
function domains_info(){
	echo " === Domains Information ======";
	echo -en "primary\t: "; grep $user /etc/trueuserdomains | cut -d : -f1;
	echo -en "addons\t: "; sed -n '/addon_domains:/,/main_domain:/p' /var/cpanel/userdata/$user/main | grep -v addon_domains | grep -v main_domain | sed '/^\s*$/d'| wc -l;
	echo -en "subs\t: "; sed -n '/sub_domains:/,//p' /var/cpanel/userdata/$user/main | grep -v sub_domains:| sed '/^\s*$/d'| wc -l;
	echo -en "parked\t: "; sed -n '/parked_domains:/,/sub_domains:/p' /var/cpanel/userdata/$user/main | grep -v parked_domains | grep -v sub_domains | sed '/^\s*$/d'| wc -l
	echo ;
}

#Getting CloudLinux faults/info for the past $days days for the account
function cl_faults(){
	echo " === CL Faults for Past $days Days ===========================";
	if [[ "$days" -eq 1 ]]; then
		lveinfo --user $user --period 24h --time-unit 1h --show-columns From To NprocF EPf VMemF PMemF CPUf IOf IOPSf
	else
		lveinfo --user $user --period "$days"d --time-unit 1d --show-columns From To NprocF EPf VMemF PMemF CPUf IOf IOPSf
	fi
	echo;
}

#Getting top 5 most intensive domains for the entire current month
function top_five(){
	echo " === Top 5 Active Domains for the Entire Month ============";
	echo -en "\t\tDomain \t\t\t\tHits \t\tGET\t\t POST\t\t OTHER \n----------------------------------\t\t-----\t\t-----\t\t -----\t\t -----\n";
	if (ls $path/ | grep -q gz); then
		for i in $(ls -hS $path | grep $currentmonth | head -5)
	do 
			echo -e $(echo -en $i|cut -d - -f1) " \t\t\t"$(zcat $path/$i|wc -l) " \t\t" $(zcat $path/$i|grep GET -c) "\t\t" $(zcat $path/$i|grep POST -c) "\t\t" $(zcat $path/$i|egrep "HEAD|PUT|DELETE|CONNECT|OPTIONS|TRACE|PATCH" -c)
	done
	else
		for i in $(ls -hS $path | head -5)
		do 
			echo -e $(echo -en $i) " \t\t\t"$(cat $path/$i|wc -l) " \t\t" $(cat $path/$i|grep GET -c) " \t\t" $(cat $path/$i|grep POST -c) " \t\t" $(cat $path/$i|egrep "HEAD|PUT|DELETE|CONNECT|OPTIONS|TRACE|PATCH" -c)
		done
	fi
	echo ;
}

#Getting top 10 IPs and user agent for all domains for the last $days days
function top_ten_ip(){
	echo " === Top 10 IP and User Agents for Past $days Days ==========";
	if (ls $path/ | grep -q gz); then
		if [[ $(zcat $path/* |awk -vDate="$(date -d "now-$days days"  +"[%d/%b/%Y")" ' { if ($4 > Date) print $1, $12, $18}' | sort | uniq -c | sort -fr | head | wc -l) -eq "0" ]]; then
			echo "There is no traffic to show for the past $days days ... ";
		else
			zcat $path/* |awk -vDate="$(date -d "now-$days days"  +"[%d/%b/%Y")" ' { if ($4 > Date) print $1, $12, $15, $16, $17, $23, $24}' |sort|uniq -c|sort -n -k1 -fr| head
		fi
	else
		if [[ $(cat $path/* |awk  '{print $1, $12, $18}' | sort | uniq -c | sort -fr | head | wc -l) -eq "0" ]]; then
			echo "There is no traffic to show for the past $days days ... ";
		else
			cat $path/* |awk '{print $1, $12, $15, $16, $17, $23, $24}' |sort|uniq -c|sort -n -k1 -fr| head
		fi
	fi
	echo ;
}

#Getting top 10 IPs only for all domains for the last $days days
function top_ten_ip_no_ua(){
	echo " === Top 10 IP without UA for Past $days Days ===============";
	if (ls $path/ | grep -q gz); then
		if [[ $(zcat $path/* |awk -vDate="$(date -d "now-$days days"  +"[%d/%b/%Y")" ' { if ($4 > Date) print $1}' | sort | uniq -c | sort -fr | head | wc -l) -eq "0" ]]; then
			echo "There is no traffic to show for the past $days days ... ";
		else
			zcat $path/* |awk -vDate="$(date -d "now-$days days"  +"[%d/%b/%Y")" ' { if ($4 > Date) print $1}' |sort|uniq -c|sort -n -k1 -fr| head
		fi
	else
		if [[ $(cat $path/* |awk '{print $1}' | sort | uniq -c | sort -fr | head | wc -l) -eq "0" ]]; then
			echo "There is no traffic to show for the past $days days ... ";
		else
			cat $path/* |awk '{print $1}' |sort|uniq -c|sort -n -k1 -fr| head
		fi
	fi
	echo ;
}

#Getting top 10 most accessed content for all sites for past $days days
function top_ten_content(){
	echo " === Top 10 Most Accessed Content/Files for Past $days Days ==="; 
	if (ls $path/ | grep -q gz); then	
		if [[ $(zcat $path/* |awk -vDate="$(date -d "now-$days days"  +"[%d/%b/%Y")" ' { if ($4 > Date) print $7}' | sort | uniq -c | sort -fr | head | wc -l) -eq "0" ]]; then
			echo "There is no traffic to show for the past $days days ... ";
		else
			zcat $path/* |awk -vDate="$(date -d "now-$days days"  +"[%d/%b/%Y")" ' { if ($4 > Date) print $7}'|sed 's/?.*//' |sort|uniq -c|sort -n -k1 -fr| head
		fi
	else
		if [[ $(cat $path/* |awk '{print $7}' | sort | uniq -c | sort -fr | head | wc -l) -eq "0" ]]; then
			echo "There is no traffic to show for the past $days days ... ";
		else
			cat $path/* |awk '{print $7}'|sed 's/?.*//' |sort|uniq -c|sort -n -k1 -fr| head
		fi
	fi
}



#Run the script if not root and user exists
if [[ $user = "root" ]]; then
	echo "Cannot run for root ... "
	exit 0
elif grep -q $user /etc/trueuserowners; then
	general_info
	domains_info
	cron_info
	get_cllimits
	cl_faults
	top_five
	top_ten_ip
	top_ten_ip_no_ua
	top_ten_content
else
	echo "User does not exist on this server ... " 
fi
