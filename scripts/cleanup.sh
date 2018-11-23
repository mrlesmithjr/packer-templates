#!/bin/bash

set -e
set -x

os="$(facter operatingsystem)"
os_family="$(facter osfamily)"

if [[ $os_family = "Debian" || $os = "Debian" ]]; then
    sudo apt-get clean
    
    elif [[ $os_family == "RedHat" ]]; then
    if [[ $os != "Fedora" ]]; then
        sudo yum clean all
        sudo rm -rf /var/cache/yum
        
        elif [[ $os == "Fedora" ]]; then
        sudo dnf clean all
    fi
fi

#Stop services for cleanup
sudo service rsyslog stop

#clear audit logs
if [ -f /var/log/audit/audit.log ]; then
    sudo bash -c "cat /dev/null > /var/log/audit/audit.log"
fi
if [ -f /var/log/wtmp ]; then
    sudo bash -c "cat /dev/null > /var/log/wtmp"
fi
if [ -f /var/log/lastlog ]; then
    sudo bash -c "cat /dev/null > /var/log/lastlog"
fi

#cleanup persistent udev rules
if [ -f /etc/udev/rules.d/70-persistent-net.rules ]; then
    sudo rm /etc/udev/rules.d/70-persistent-net.rules
fi

#cleanup /tmp directories
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

#cleanup current ssh keys
sudo rm -f /etc/ssh/ssh_host_*

#reset hostname
sudo bash -c "cat /dev/null > /etc/hostname"

#cleanup shell history
history -w
history -c