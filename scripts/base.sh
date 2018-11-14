#!/bin/bash

set -e
set -x

codename="$(facter lsbdistcodename)"
os="$(facter operatingsystem)"
os_family="$(facter osfamily)"
os_release="$(facter operatingsystemrelease)"

if [[ $os_family == "Debian" ]]; then
    # We need to cleanup for old repo update issues for hash mismatch
    if [[ $codename == "precise" ]]; then
        sudo apt-get clean
        sudo rm -r /var/lib/apt/lists/*
    fi
    sudo apt-get update
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
    
    elif [[ $os_family == "RedHat" ]]; then
    if [[ $os != "Fedora" ]]; then
        sudo yum -y install python-devel
        
        elif [[ $os == "Fedora" ]]; then
        sudo dnf -y install python-devel python-dnf
    fi
fi