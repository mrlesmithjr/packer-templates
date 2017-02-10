#!/bin/bash

# Set up Vagrant.

date > /etc/vagrant_box_build_time

# Create the user vagrant with password vagrant
useradd -G sudo -p $(perl -e'print crypt("vagrant", "vagrant")') -m -s /bin/bash -N vagrant

# Set up sudo.  Be careful to set permission BEFORE copying file to sudoers.d
( cat <<EOP
%vagrant ALL=(ALL) NOPASSWD:ALL
EOP
) > /tmp/vagrant
chmod 0440 /tmp/vagrant
mv /tmp/vagrant /etc/sudoers.d/

# Install vagrant keys
mkdir -pm 700 /home/vagrant/.ssh
curl -Lo /home/vagrant/.ssh/authorized_keys \
  'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub'
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

# Customize the message of the day
echo 'Welcome to your Vagrant-built virtual machine.' > /var/run/motd
