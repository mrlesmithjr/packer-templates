#!/bin/bash

set -e
set -x

os="$(facter operatingsystem)"
os_family="$(facter osfamily)"
os_release="$(facter operatingsystemrelease)"
os_release_major="$(facter operatingsystemrelease | awk -F. '{ print $1 }')"

if [ "$PACKER_BUILDER_TYPE" != "vmware-iso" ]; then
    exit 0
fi

# Debian/Ubuntu
if [[ $os_family = "Debian" || $os = "Debian" ]]; then
    # We look for this artifact for Ubuntu when desktop.sh script has been ran.
    # Only Ubuntu experiences this issue so far. Debian desktops work fine.
    if [ -f /etc/vmware_desktop ]; then
        sudo apt-get install -y open-vm-tools-desktop
    else
        sudo apt-get install -y open-vm-tools
    fi
    
    elif [[ $os_family = "RedHat" ]]; then
    if [[ $os != "Fedora" ]]; then
        if [ -f /etc/vmware_desktop ]; then
            sudo yum -y install open-vm-tools-desktop
        else
            sudo yum -y install open-vm-tools
        fi
        if [[ $os_release_major -ge 7 ]]; then
            sudo /bin/systemctl restart vmtoolsd.service
        else
            sudo service vmtoolsd restart
        fi
        
        elif [[ $os = "Fedora" ]]; then
        if [ -f /etc/vmware_desktop ]; then
            sudo dnf -y install open-vm-tools-desktop
        else
            sudo dnf -y install open-vm-tools
        fi
        sudo /bin/systemctl restart vmtoolsd.service
    fi
    
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