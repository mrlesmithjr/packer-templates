#!/bin/bash

if test -f .vbox_version ; then
  # The netboot installs the VirtualBox support (old) so we have to remove it
  if test -f /etc/init.d/virtualbox-ose-guest-utils ; then
    /etc/init.d/virtualbox-ose-guest-utils stop
  fi

  rmmod vboxguest
  apt-get -y purge virtualbox-ose-guest-x11 virtualbox-ose-guest-dkms virtualbox-ose-guest-utils

  # Install dkms for dynamic compiles

  apt-get install -y dkms

  # If libdbus is not installed, virtualbox will not autostart
  apt-get -y install --no-install-recommends libdbus-1-3

  # Install the VirtualBox guest additions
  mount -o loop /home/vagrant/VBoxGuest*.iso /mnt
  yes|sh /mnt/VBoxLinuxAdditions.run --nox11
  umount /mnt
  rm -rf /home/vagrant/VBoxGuest*.iso

  # Start the newly build driver
#  /etc/init.d/vboxadd start
fi
