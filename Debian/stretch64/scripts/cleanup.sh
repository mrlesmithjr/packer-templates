#!/bin/bash

set -e

# Clean up
apt-get -y remove linux-headers-$(uname -r) build-essential
apt-get -y autoremove
apt-get -y clean

# Removing leftover leases and persistent rules
echo "cleaning up dhcp leases"
rm /var/lib/dhcp/*

# Make sure Udev doesn't block our network
echo "cleaning up udev rules"
if [ -d /etc/udev/rules.d/70-persistent-net.rules ]; then
  rm -rf /etc/udev/rules.d/70-persistent-net.rules
fi
# mkdir /etc/udev/rules.d/70-persistent-net.rules
if [ -d /dev/.udev/ ]; then
  rm -rf /dev/.udev/
fi
if [ -f /lib/udev/rules.d/75-persistent-net-generator.rules ]; then
  rm /lib/udev/rules.d/75-persistent-net-generator.rules
fi

echo "Adding a 2 sec delay to the interface up, to make the dhclient happy"
echo "pre-up sleep 2" >> /etc/network/interfaces
