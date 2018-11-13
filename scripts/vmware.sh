#!/bin/bash

set -e
set -x

if [ "$PACKER_BUILDER_TYPE" != "vmware-iso" ]; then
  exit 0
fi

# Debian/Ubuntu
if [ -f /etc/debian_version ]; then
  sudo apt-get install -y open-vm-tools
fi

# RHEL
if [ -f /etc/redhat-release ]; then
  codename="$(facter operatingsystem)"
  if [[ $codename != "Fedora" ]]; then
    sudo yum -y install open-vm-tools
  fi
  if [[ $codename == "Fedora" ]]; then
    sudo dnf -y install open-vm-tools
  fi
  sudo /bin/systemctl restart vmtoolsd.service
fi