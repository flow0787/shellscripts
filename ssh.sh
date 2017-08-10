#!/bin/bash
#SCRIPT WHICH AUTOMATICALLY CHANGES THE HOSTNAME IN THE TERMINAL TITLE BAR#
#USAGE: alias ssh="/path/to/ssh.sh -p $PORT -l $USER"
# trim parameters, leaving just the last (user@hostname or just hostname)
title=$(echo "$*" | sed -e 's/^.* //')
printf '\033]0;%s\007' "$title"
/usr/bin/ssh "$@"
