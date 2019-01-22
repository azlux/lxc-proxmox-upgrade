#!/usr/bin/env bash

update () {
    echo "------------------------------"
    echo "  Send to $1..."
    echo "------------------------------"
    sudo lxc-attach -n $1 -- apt update -qq
    sudo lxc-attach -n $1 -- apt upgrade -q -y
    sudo lxc-attach -n $1 -- apt autoremove

    if [ $2 -eq 1 ]; then
    	sudo lxc-attach -n $1 -- /root/maj 
    fi
}

# Need "all" or container ID
if [ -z "$1" ]; then
    echo "usage: <all>|<contid>"
    exit 1
fi

# Upgrade all active containers
if [ "all" = "$1" ]; then
    read -p "Full update (y/n)?" choice
    case "$choice" in 
        y|Y ) full=1;;
	*   ) full=0;;
    esac

    for cx in `sudo lxc-ls --active --line`; do
        update $cx $full
    done

    echo "------------------------------"
    echo "        Proxmox ..."
    echo "------------------------------"
    sudo apt update
    sudo apt upgrade
    exit
fi

# Should be a container
read -p "Full update (y/n)?" choice
case "$choice" in 
    y|Y ) update $1 1;;
    *   ) update $1 0;;
esac

