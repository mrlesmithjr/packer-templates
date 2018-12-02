#!/bin/bash

set -e
set -x

os="$(facter operatingsystem)"

# Vagrant specific
sudo bash -c "date > /etc/vagrant_box_build_time"

# Installing vagrant keys
if [ -f /etc/vyos_build ]; then
    WRAPPER=/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper
    PUBLIC_KEY=$(curl -fsSL -A curl 'https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub')
    KEY_TYPE=$(echo "$PUBLIC_KEY" | awk '{print $1}')
    KEY=$(echo "$PUBLIC_KEY" | awk '{print $2}')
    $WRAPPER begin
    $WRAPPER set system login user vagrant authentication public-keys vagrant type "$KEY_TYPE"
    $WRAPPER set system login user vagrant authentication public-keys vagrant key "$KEY"
    $WRAPPER commit
    $WRAPPER save
    $WRAPPER end
else
    sudo mkdir -pm 700 /home/vagrant/.ssh
    sudo sh -c "curl -L https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub -o /home/vagrant/.ssh/authorized_keys"
    sudo chmod 0600 /home/vagrant/.ssh/authorized_keys
    sudo chown -R vagrant /home/vagrant/.ssh
fi
# We need to do this here as our autoinst.xml does not do it for us
if [[ $os = *openSUSE* || $os = *OpenSuSE* ]]; then
    echo "vagrant        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
fi