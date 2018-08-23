#!/bin/bash
# A shell script to review a cPanel account's traffic information and resource usage statistics 
# Usage: ./analyzer.sh $user $month 
# month = 3 letter abbreviaton of current month, first letter capitalized
# -------------------------------------------------------------------------
# Copyright (c) 2018 FlorinBadea a bunch of helpful scripts project 
# This script is licensed under GNU GPL version 2.0 or above
# -------------------------------------------------------------------------
# LOG FILTER:
# https://stackoverflow.com/questions/7706095/filter-log-file-entries-based-on-date-range

user=$1
month=$2

#Getting general account information
echo " === General Info =============";
echo -en "username\t: $user \n";
echo -en "hosting plan\t: " ; grep PLAN /var/cpanel/users/$user | cut -d = -f2


#Getting domain information
echo " === Domains Information ======";
echo -en "primary\t: "; grep $user /etc/trueuserdomains | cut -d : -f1;
echo -en "addons\t: "; sed -n '/addon_domains:/,/main_domain:/p' /var/cpanel/userdata/$user/main | grep -v addon_domains | grep -v main_domain |wc -l;
echo -en "subs\t: "; sed -n '/sub_domains:/,//p' /var/cpanel/userdata/$user/main | grep -v sub_domains:| wc -l;
echo -en "parked\t: "; sed -n '/parked_domains:/,/sub_domains:/p' /var/cpanel/userdata/$user/main | grep -v parked_domains | grep -v sub_domains |wc -l


#Getting CloudLinux faults/info for the past 10 days for the account
echo " === CL faults for past 10 days ===========================";
lveinfo --user $user --period 10d --time-unit 1d --show-columns From To NprocF EPf VMemF PMemF CPUf IOf IOPSf


#Getting top 3 most intensive domains for the entire month
echo " === Top 3 Active Domains ===============================";
for i in $(ls -lahS logs/ | grep $month | head -3 | awk {'print $9'})
do 
		echo -en $i|cut -d - -f1; zcat logs/$i|wc -l
done


#Getting top 10 IPs and user agent for all domains for the last 5 days
echo " === Top 10 IP Addresses ================================";
zcat logs/*-$month-* |awk -vDate=`date -d'now-5 days' +[%d/%b/%Y:%H:%M:%S` ' { if ($4 > Date) print $1, $12, $18}' | sort | uniq -c | sort -fr | head


#Getting top 10 IPs and user agent for top 3 most intensive domains for past 5 days
echo " === Top 10 IPs For Top 5 Sites For Past 5 Days =========";
for i in $(ls -lahS logs/ | grep $month | head -3 | awk {'print $9'})
do 
		echo -en "=== " $i|cut -d - -f1; zcat logs/$i |awk -vDate=`date -d'now-5 days' +[%d/%b/%Y:%H:%M:%S` ' { if ($4 > Date) print $1, $12, $18}' | sort | uniq -c | sort -fr | head; echo -en "\n";
done


#Getting top 10 most accessed content for all sites for past 5 days
echo " === Top 10 Most Accessed Content/Files =================="; 
zcat logs/*-$month-* |awk -vDate=`date -d'now-5 days' +[%d/%b/%Y:%H:%M:%S` ' { if ($4 > Date) print $7}' | sort | uniq -c | sort -fr | head

zcat logs/*-Aug*|egrep "20/Aug|21/Aug|22/Aug|23/Aug|24/Aug|25/Aug"|awk '{print $7}' | cut -d? -f1|sort|uniq -c|sort -nk1|tail -n10 | sort -rnk1
