#!/bin/bash

VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
cd /tmp
#yum -y groupinstall 'Development Tools'
#wget http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm
#rpm -Uvh rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm
#yum -y --enablerepo=rpmforge install dkms
mount -o loop /home/vagrant/VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt
/etc/rc.d/init.d/vboxadd setup
rm -rf /home/vagrant/VBoxGuestAdditions_*.iso
