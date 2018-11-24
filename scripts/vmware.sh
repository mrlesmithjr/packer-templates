#!/bin/bash

set -e
set -x

os="$(facter operatingsystem)"
os_family="$(facter osfamily)"

if [ "$PACKER_BUILDER_TYPE" != "vmware-iso" ]; then
    exit 0
fi

# Debian/Ubuntu
if [[ $os_family = "Debian" || $os = "Debian" ]]; then
    sudo apt-get install -y open-vm-tools
    
    elif [[ $os_family = "RedHat" ]]; then
    if [[ $os != "Fedora" ]]; then
        sudo yum -y install open-vm-tools
        
        elif [[ $os = "Fedora" ]]; then
        sudo dnf -y install open-vm-tools
    fi
    sudo /bin/systemctl restart vmtoolsd.service
    
    elif [[ $os_family = "Suse" ]]; then
    sudo zypper --non-interactive install open-vm-tools
    
    elif [[ $os_family = "Linux" ]]; then
    if [[ $os = "Alpine" ]]; then
        apk add open-vm-tools || true
    fi
    elif [[ $os_family = "Archlinux" ]]; then
    sudo /usr/bin/pacman -S --noconfirm linux-headers open-vm-tools nfs-utils
    sudo /usr/bin/systemctl enable vmtoolsd.service
    sudo /usr/bin/systemctl enable rpcbind.service
fi