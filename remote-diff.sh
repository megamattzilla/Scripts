#!/bin/bash
#first argument is username@remote_host. Will prompt for password because security. optionally an ssh key would work. 
#second argument is command to execute on both local and remote systems. by default the data is sorted to make diff of large data sets easier. remote sort if needed. 
#third argument is diff with desired flags
##example## ./remote-diff.sh root@192.168.1.247 "sessiondump -allkeys" "vimdiff" 

#Run command on local system and send output to local-diff.txt
$2 | sort > local-diff.txt

#login to remote system, run command, and sent output to remote-diff.txt
ssh $1 "$2" | sort > remote-diff.txt

#compare local-diff and remote-diff 
$3 local-diff.txt remote-diff.txt