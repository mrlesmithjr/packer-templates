#!/bin/bash

set -e
set -x

os="$(facter operatingsystem)"

# Vagrant specific
sudo bash -c "date > /etc/vagrant_box_build_time"

# Installing vagrant keys
sudo mkdir -pm 700 /home/vagrant/.ssh
sudo sh -c "curl -L https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub -o /home/vagrant/.ssh/authorized_keys"
sudo chmod 0600 /home/vagrant/.ssh/authorized_keys
sudo chown -R vagrant /home/vagrant/.ssh

# We need to do this here as our autoinst.xml does not do it for us
if [[ $os = *openSUSE* || $os = *OpenSuSE* ]]; then
    echo "vagrant        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
fi