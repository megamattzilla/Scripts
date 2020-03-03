#!/bin/bash
#first argument is username@remote_host. Will prompt for password because security. optionally an ssh key would work. 
#second argument is command to execute on both local and remote systems. by default the data is sorted to make diff of large data sets easier. remote sort if needed. 
#third argument is diff with desired flags
##example## ./remote-diff.sh root@192.168.1.247 "sessiondump -allkeys" "vimdiff" 
local=/shared/tmp/local-diff.txt  #local file location
remote=/shared/tmp/remote-diff.txt #remote file location 

if [ -z "$1" ] && [ -z "$2" ] && [ -z "$3" ]
then
      echo "Invalid argument. Expecting: ./remote-diff.sh <user>@<host> \"<command to execute>\" \"<diff command and desired flags>\""
      echo "Example: ./remote-diff.sh root@192.168.1.247 \"sessiondump -allkeys\" \"vimdiff\""
else
    #login to remote system, run command, and sent output to remote-diff.txt
    ssh $1 "$2" | sort > $remote

        #Run command on local system and send output to local-diff.txt
    $2 | sort > $local  
    sleep 2

    if /bin/cmp -s "$local" "$remote"; then
        echo "local and remote command output is identical."
    else
        #compare local-diff and remote-diff 
        $3 $local $remote
    fi

fi