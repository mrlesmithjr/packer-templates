#!/bin/bash

set -e
set -x

# This does not seem to be working as of right now. Need to investigate.
if [ "$PACKER_BUILDER_TYPE" != "virtualbox-iso" ]; then
    exit 0
fi

# Debian/Ubuntu
if [ -f /etc/debian_version ]; then
    os="$(facter operatingsystem)"
    if [[ $os == "Ubuntu" ]]; then
        sudo apt-get install -y virtualbox-guest-utils
        sudo rm -rf /home/vagrant/VBoxGuestAdditions*.iso
        elif [[ $os == "Debian" ]]; then
        sudo mkdir -p /mnt/virtualbox
        sudo mount -o loop /home/vagrant/VBoxGuestAdditions*.iso /mnt/virtualbox
        sudo sh /mnt/virtualbox/VBoxLinuxAdditions.run
        sudo umount /mnt/virtualbox
        sudo rm -rf /home/vagrant/VBoxGuestAdditions*.iso
    fi
fi

# RHEL
if [ -f /etc/redhat-release ]; then
    codename="$(facter operatingsystem)"
    if [[ $codename != "Fedora" ]]; then
        sudo yum -y install gcc kernel-devel kernel-headers dkms make bzip2 perl && \
        sudo yum -y groupinstall "Development Tools"
    fi
    if [[ $codename == "Fedora" ]]; then
        sudo dnf -y install gcc kernel-devel kernel-headers dkms make bzip2 perl && \
        sudo dnf -y groupinstall "Development Tools"
    fi
    sudo mkdir -p /mnt/virtualbox
    sudo mount -o loop /home/vagrant/VBoxGuest*.iso /mnt/virtualbox
    sudo sh /mnt/virtualbox/VBoxLinuxAdditions.run
    sudo umount /mnt/virtualbox
    sudo rm -rf /home/vagrant/VBoxGuest*.iso
fi