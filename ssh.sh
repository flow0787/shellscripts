#!/bin/bash
# Description     : SCRIPT WHICH AUTOMATICALLY CHANGES THE HOSTNAME IN THE TERMINAL TITLE BAR
# Usage           : alias ssh="/path/to/ssh.sh -p $PORT -l $USER"
#					trim parameters, leaving just the last (user@hostname or just hostname)
#---------------------------------------------------------------------------------#
# Author		  : Florin Badea
# Source		  : https://github.com/flow0787/shellscripts
#---------------------------------------------------------------------------------#
# Date            : sometime in 2017
# Updated         : -
# Requirements    : SHELL + SSH
# References      : N/A
#=================================================================================#


title=$(echo "$*" | sed -e 's/^.* //')
printf '\033]0;%s\007' "$title"
/usr/bin/ssh "$@"
