# Installing the virtualbox guest additions
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
cd /tmp
mount -o loop /home/vagrant/VBoxGuestAdditions_$VBOX_VERSION.iso /mnt || echo "unable to mount virtual box guest addtions iso"
sh /mnt/VBoxLinuxAdditions.run install --force || echo "unable to install driver"
umount /mnt || echo "unable to umount iso"
rm -rf /home/vagrant/VBoxGuestAdditions_*.iso || echo "unable to rm iso"
echo "guest additions installed"

