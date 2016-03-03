#!/bin/bash

# Fix Ubuntu 12.04.5 checksum mismatch
echo "==> Checking if OS is Ubuntu Precise"
if [ -f /etc/debian_version ]; then
  codename="$(lsb_release -c | awk {'print $2}')"
  if [ $codename == "precise" ]; then
    rm -rf /var/lib/apt/lists/* && \
    apt-get -y update && \
    sync
  fi
fi

# Update the box
apt-get -y update
apt-get -y install linux-headers-$(uname -r) build-essential
apt-get -y install zlib1g-dev libssl-dev libreadline-gplv2-dev
apt-get -y install facter curl unzip

# Tweak sshd to prevent DNS resolution (speed up logins)
echo 'UseDNS no' >> /etc/ssh/sshd_config

# Remove 5s grub timeout to speed up booting
cat <<EOF > /etc/default/grub
# If you change this file, run 'update-grub' afterwards to update
# /boot/grub/grub.cfg.

GRUB_DEFAULT=0
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX="debian-installer=en_US"
EOF

update-grub
