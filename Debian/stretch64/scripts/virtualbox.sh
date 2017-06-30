#!/bin/bash

set -e

# Install dkms for dynamic compiles
apt-get install -y dkms

# Prepare Debian 9 system to build kernel module
m-a prepare

mkdir -p /mnt/virtualbox
mount -o loop /home/vagrant/VBoxGuest*.iso /mnt/virtualbox
sh /mnt/virtualbox/VBoxLinuxAdditions.run
umount /mnt/virtualbox
rm -rf /home/vagrant/VBoxGuest*.iso
