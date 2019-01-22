#!/usr/bin/env bash

send () {
    echo "------------------------------"
    echo "  Send to $1..."
    echo "------------------------------"
    sudo lxc-attach -n $1 -- ${@:2}
}

# Need "all" or container ID
if [ -z "$1" ]; then
    echo "usage: <all>|<contid> command"
    exit 1
fi

if [ -z "$2" ]; then
     echo "command is missing"
     exit 1
fi

# Upgrade all active containers
if [ "all" = "$1" ]; then
    for cx in `sudo lxc-ls --active --line`; do
        send $cx ${@:2}
    done
    exit
fi

# Should be a container
send $1 ${@:2}
