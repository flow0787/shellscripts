#!/bin/bash
if [[ -z $1 ]]; then echo "Need user"; exit; fi # failearly
SERVERS=($(curl -s https://galaxy.sgvps.net/backups/scripts.php?user=$1 |awk '{print $4}' | sort -u ))
if [[ -z ${SERVERS[1]} ]]; then
   echo -e "Server: ${SERVERS[0]} \nUsername: $1"
   ssh -p18765 -o StrictHostKeyChecking=no $1@${SERVERS[0]}
else
  for i in ${SERVERS[*]}; do echo "ssh -p18765 $1@$i"; done
fi
