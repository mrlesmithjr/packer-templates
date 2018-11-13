#!/bin/bash

set -e
set -x

# Debian/Ubuntu
if [ -f /etc/debian_version ]; then
    codename="$(facter lsbdistcodename)"
    
    # We need to cleanup for old repo update issues for hash mismatch
    if [[ $codename == "precise" ]]; then
        sudo apt-get clean
        sudo rm -r /var/lib/apt/lists/*
    fi
    
    #update apt-cache
    sudo apt-get update
    
    #install packages
    sudo apt-get install -y python-minimal linux-headers-$(uname -r) \
    build-essential zlib1g-dev libssl-dev libreadline-gplv2-dev unzip
    
    # Check for /etc/rc.local and create if needed. This has been depricated in
    # Debian 9 and later. So we need to resolve this in order to regenerate SSH host
    # keys.
    if [ ! -f /etc/rc.local ]; then
    sudo bash -c "cat <<EOF >/etc/rc.local
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

exit 0
EOF"
        
        sudo chmod +x /etc/rc.local
        sudo systemctl daemon-reload
        sudo systemctl enable rc-local
        sudo systemctl start rc-local
    fi
    
    if [ -f /etc/rc.local ]; then
        #add check for ssh keys on reboot...regenerate if neccessary
        sudo bash -c "sed -i -e 's|exit 0||' /etc/rc.local"
        sudo bash -c "sed -i -e 's|.*test -f /etc/ssh/ssh_host_dsa_key.*||' /etc/rc.local"
        sudo bash -c "echo 'test -f /etc/ssh/ssh_host_dsa_key || dpkg-reconfigure openssh-server' >> /etc/rc.local"
        sudo bash -c "echo 'exit 0' >> /etc/rc.local"
    fi
fi

# RHEL
if [ -f /etc/redhat-release ]; then
    codename="$(facter operatingsystem)"
    if [[ $codename != "Fedora" ]]; then
        sudo yum -y install python-devel
    fi
    if [[ $codename == "Fedora" ]]; then
        sudo dnf -y install python-devel python-dnf
    fi
fi