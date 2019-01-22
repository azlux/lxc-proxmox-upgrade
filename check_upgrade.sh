#!/usr/bin/env bash
packages_to_upgrade=()
regex="The following packages will be upgraded:\s(.*)[0-9]+ upgraded, [0-9]+ newly installed, [0-9]+ to remove"
check_update () {
    sudo lxc-attach -n $1 -- apt-get update -qq
    res=$(sudo lxc-attach -n $1 -- apt-get upgrade --show-upgraded --assume-no)
    res="${res//[$'\t\r\n']}"
    if [[ "$res" =~ $regex ]]; then
	packages_to_upgrade+=${BASH_REMATCH[1]}
    fi
}

# Upgrade all active containers
for cx in `sudo lxc-ls --active --line`; do
    check_update $cx
done

echo $packages_to_upgrade

apt-get update -qq
res=$(apt-get upgrade --show-upgraded --assume-no)
res="${res//[$'\t\r\n']}"
if [[ "$res" =~ $regex ]]; then
    packages_to_upgrade+=${BASH_REMATCH[1]}
fi

if [ ! -z "$packages_to_upgrade" ]; then
    res=$(echo $packages_to_upgrade | tr ' ' '\n' | sort | uniq -c)
    mail -s "Proxmox upgrade list" root <<< "Packages waiting for upgrade\n$res"
fi

