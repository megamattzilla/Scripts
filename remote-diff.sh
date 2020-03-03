#!/bin/bash
#first argument is username@remote_host. Will prompt for password because security. optionally an ssh key would work. 
#second argument is command to execute on both local and remote systems. by default the data is sorted to make diff of large data sets easier. remote sort if needed. 
#third argument is diff with desired flags
#forth arugment is option- an in-line filter string to remote lines to ignore in the diff 


#variables 
local=/shared/tmp/local-diff.txt  #local file location
remote=/shared/tmp/remote-diff.txt #remote file location 

#sanity check for required arguments 1-3  
if [ -z "$1" ] && [ -z "$2" ] && [ -z "$3" ]; then
      echo "Invalid argument. Expecting syntax: ./remote-diff.sh <user>@<host> \"<command to execute>\" \"<diff command and desired flags>\" \"[OPTIONAL: in-line filter string]\""
      echo "Example syntax: ./remote-diff.sh root@192.168.1.247 \"sessiondump -allkeys\" \"vimdiff\" \"grep -v session.stats.bytes\""
else
    #Check for option 4th argument to ignore lines in local and remote commands 
    if [ -z "$4" ]; then
        #login to remote system, run command, and sent output to $remote
        ssh $1 "$2" | sort > $remote

        #Run command on local system and send output to $local
        $2 | sort > $local  
    else
        #login to remote system, run command, add extra filter, and sent output to remote-diff.txt
        ssh $1 "$2" | $4 | sort > $remote

        #Run command on local system, add extra filter, and send output to local-diff.txt
        $2 | $4 | sort > $local  
    fi    

    #check if files are identical before running diff. seems counter intuitive but most diff commands dont expliclly tell you when files are identical. 
    if /bin/cmp -s "$local" "$remote"; then
        echo "local and remote command output is identical."
    else
        #compare local-diff and remote-diff 
        $3 $local $remote
    fi
fi