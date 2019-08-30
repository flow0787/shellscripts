#!/bin/bash
# AUTHOR: FLORIN BADEA for Support Eng application @ GitLab
# DESCRIPTION: Script that checks for changes the users and their home folder on a linux system
# taking into account two md5 hashes
# PREREQUISITES: an initial md5 hash taking into account the initial system state, for this, we need to run:
# cat /etc/passwd | awk -F ':' -v OFS=':' {'print $1,$6'} | md5sum | cut -d " " -f 1 > /var/log/current_users

# we obtain the list of all users on the system and their home
# in the form of user:/home/dir then pipe it over to md5sum
# to generate an md5 hash which we save in cron_hash
cron_hash=`cat /etc/passwd | awk -F ':' -v OFS=':' {'print $1,$6'} | md5sum | cut -d " " -f 1`;

# current system state (the initial hash we obtained at the PREREQUEISITES step
initial_hash=`cat /var/log/current_users`



# if the generated hash is not the same as initial system hash
if [ "$cron_hash" != "$initial_hash" ]; then
        # log this as DATE TIME changes occured in /var/log/user_changes
        echo $(date +"%m-%d-%y %T") changes occured >> /var/log/user_changes
        # replace the initial system hash to our new hash
        echo $cron_hash > /var/log/current_users
else
        # if it is the same then do nothing
        :
fi
#### END SCRIPT ####
