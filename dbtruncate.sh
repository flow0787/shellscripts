#!/bin/bash
# Description     : This empties the tables in a database without removing the database
# Usage           : ./dbtruncate.sh $db_user $db_pass $db_name
#---------------------------------------------------------------------------------#
# Author		  : Florin Badea
# Source		  : https://github.com/flow0787/shellscripts
#---------------------------------------------------------------------------------#
# Date            : sometime in 2017
# Requirements    : SHELL + MySQL
# References      : based on nixCraft database truncate script at https://bash.cyberciti.biz/
#=================================================================================#


MUSER="$1"
MPASS="$2"
MDB="$3"
 
# Detect paths
MYSQL=$(which mysql)
AWK=$(which awk)
GREP=$(which grep)
 
if [ $# -ne 3 ]
then
	echo "Usage: $0 {MySQL-User-Name} {MySQL-User-Password} {MySQL-Database-Name}"
	echo "Drops all tables from a MySQL"
	exit 1
fi
 
TABLES=$($MYSQL -u $MUSER -p$MPASS $MDB -e 'show tables' | $AWK '{ print $1}' | $GREP -v '^Tables' )
 
for t in $TABLES
do
	$MYSQL -u $MUSER -p$MPASS $MDB -e "SET FOREIGN_KEY_CHECKS=0"
	echo "Deleting $t table from $MDB database..."
	$MYSQL -u $MUSER -p$MPASS $MDB -e "drop table $t"
done
