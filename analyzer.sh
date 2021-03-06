#!/bin/bash
# Description     : A shell script to review a cPanel account's traffic information 
#				    and resource usage statistics 
# Usage           : ./analyzer.sh $user
#---------------------------------------------------------------------------------#
# Author		  : Florin Badea
# Source		  : https://github.com/flow0787/shellscripts
#---------------------------------------------------------------------------------#
# Date            : 03-08-2018
# Requirements    : SHELL + LVEINFO/CloudLinux
# References      : https://stackoverflow.com/questions/7706095/filter-log-file-entries-based-on-date-range
#=================================================================================#


user=$1
#month=$2
path=/home/$user/logs

#Arguments verification check
if [[ $# -eq 0 ]]; then
	echo -e "Please provide a cPanel user ..."
	exit 0
elif [[ $# -gt 1 ]]; then
	echo -e "You provided more than 1 argument! Exitting ..."
	exit 0
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
	echo;
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

#Getting CloudLinux faults/info for the past 10 days for the account
function cl_faults(){
	echo " === CL Faults for Past 10 Days ===========================";
	lveinfo --user $user --period 10d --time-unit 1d --show-columns From To NprocF EPf VMemF PMemF CPUf IOf IOPSf
	echo;
}

#Getting top 5 most intensive domains for the entire month
function top_three(){
	echo " === Top 5 Active Domains for the Entire Month ============";
	echo -en "          Domain                Hits     GET      POST   OTHER \n------------------------       -----    ------    -----   -----\n";	
	for i in $(ls -hS $path | grep gz| head -5)
	do 
			#echo -e $(echo -en $i) " \t : \t"$(zcat $path/$i|wc -l)
			echo -e $(echo -en $i|cut -d - -f1) " \t"$(zcat $path/$i|wc -l) " \t" $(zcat $path/$i|grep GET -c) "\t" $(zcat $path/$i|grep POST -c) "\t" $(zcat $path/$i|egrep "HEAD|PUT|DELETE|CONNECT|OPTIONS|TRACE|PATCH" -c)
	done
	echo ;
}




#Getting top 10 IPs and user agent for all domains for the last 5 days
function top_ten_ip(){
	echo " === Top 10 IP Addresses and User Agents ===================";
	if [[ $(zcat $path/* |awk -vDate=`date -d'now-5 days' +[%d/%b/%Y:%H:%M:%S` ' { if ($4 > Date) print $1, $12, $18}' | sort | uniq -c | sort -fr | head | wc -l) -eq "0" ]]; then
		echo "There is no traffic to show for the past 5 days ... ";
	else
		zcat $path/* |awk -vDate=`date -d'now-5 days' +[%d/%b/%Y:%H:%M:%S` ' { if ($4 > Date) print $1, $12, $15, $16, $17, $23, $24}' | sort | uniq -c | sort -fr | head
	fi
	echo ;
}

#Getting top 10 IPs only for all domains for the last 5 days
function top_ten_ip_no_ua(){
	echo " === Overall Top 10 IP Addresses without UA =================";
	if [[ $(zcat $path/* |awk -vDate=`date -d'now-5 days' +[%d/%b/%Y:%H:%M:%S` ' { if ($4 > Date) print $1}' | sort | uniq -c | sort -fr | head | wc -l) -eq "0" ]]; then
		echo "There is no traffic to show for the past 5 days ... ";
	else
		zcat $path/* |awk -vDate=`date -d'now-5 days' +[%d/%b/%Y:%H:%M:%S` ' { if ($4 > Date) print $1}' | sort | uniq -c | sort -fr | head
	fi
	echo ;
}


#Getting top 10 IPs and user agent for top 3 most intensive domains for past 5 days
#function top_ten_three(){
	#echo " === Top 10 IPs For Top 3 Sites For Past 5 Days =========";
	#for i in $(ls -hS $path | head -3 | awk {'print $9'})
	#do 
	#		echo -en " --> " $i|cut -d - -f1; zcat $path/$i |awk -vDate=`date -d'now-5 days' +[%d/%b/%Y:%H:%M:%S` ' { if ($4 > Date) print $1, $12, $18}' | sort | uniq -c | sort -fr | head; echo -en "\n";
	#done
	#echo ;
#}

#Getting top 10 most accessed content for all sites for past 5 days
function top_ten_content(){
	echo " === Top 10 Most Accessed Content/Files =================="; 
	if [[ $(zcat $path/* |awk -vDate=`date -d'now-5 days' +[%d/%b/%Y:%H:%M:%S` ' { if ($4 > Date) print $7}' | sort | uniq -c | sort -fr | head | wc -l) -eq "0" ]]; then
		echo "There is no traffic to show for the past 5 days ... ";
	else
		zcat $path/* |awk -vDate=`date -d'now-5 days' +[%d/%b/%Y:%H:%M:%S` ' { if ($4 > Date) print $7}'|sed 's/?.*//' | sort | uniq -c | sort -fr | head
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
	cl_faults
	top_three
	top_ten_ip
	top_ten_ip_no_ua
	top_ten_content
else
	echo "User does not exist on this server ... " 
fi
