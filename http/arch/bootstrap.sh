#!/usr/bin/env bash

# Credit to https://github.com/elasticdog/packer-arch for most of this script

set -e
set -x

CHROOT_DIR="/mnt"
DISK="/dev/sda"
ROOT_PART="/dev/sda1"
MIRRORLIST="https://www.archlinux.org/mirrorlist/?country=US&protocol=http&protocol=https&ip_version=4&use_mirror_status=on"
PASSWORD=$(/usr/bin/openssl passwd -crypt 'vagrant')

echo -e "Downloading mirror list..."
curl -s "$MIRRORLIST" | sed 's/^#Server/Server/' >/etc/pacman.d/mirrorlist

echo -e "Clearing partition table..."
/usr/bin/sgdisk --zap $DISK

echo -e "Wiping disk..."
/usr/bin/dd if=/dev/zero of=$DISK bs=512 count=2048
/usr/bin/wipefs --all $DISK

echo -e "Creating root partition..."
/usr/bin/sgdisk --new=1:0:0 $DISK

echo -e "Marking root partition as bootable..."
/usr/bin/sgdisk $DISK --attributes=1:set:2

echo -e "Creating /root filesystem..."
/usr/bin/mkfs.ext4 -O ^64bit -F -m 0 -q -L root $ROOT_PART

echo -e "Mounting root partition..."
/usr/bin/mount -o noatime,errors=remount-ro $ROOT_PART $CHROOT_DIR

echo -e "Bootstrapping base installation..."
/usr/bin/pacstrap $CHROOT_DIR base base-devel linux linux-firmware
/usr/bin/arch-chroot $CHROOT_DIR pacman -S --noconfirm dhcpcd gptfdisk openssh syslinux
/usr/bin/arch-chroot $CHROOT_DIR syslinux-install_update -i -a -m
/usr/bin/sed -i "s|sda3|sda1|" "$CHROOT_DIR/boot/syslinux/syslinux.cfg"
/usr/bin/sed -i "s/TIMEOUT 50/TIMEOUT 10/" "$CHROOT_DIR/boot/syslinux/syslinux.cfg"

echo -e "Generating filesystem table..."
/usr/bin/genfstab -p $CHROOT_DIR >>"$CHROOT_DIR/etc/fstab"

echo -e "Generating config script..."
/usr/bin/install --mode=0755 /dev/null "$CHROOT_DIR/usr/local/bin/arch-config.sh"

cat <<-EOF >"$CHROOT_DIR/usr/local/bin/arch-config.sh"
    echo -e "Configuring base system..."
    echo "localhost" > /etc/hostname
    /usr/bin/ln -s /usr/share/zoneinfo/UTC /etc/localtime
    echo 'KEYMAP=us' > /etc/vconsole.conf
    /usr/bin/sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
    /usr/bin/locale-gen
    /usr/bin/mkinitcpio -p linux
    /usr/bin/usermod --password $PASSWORD root
    if [[ /etc/udev/rules.d/80-net-setup-link.rules ]]; then
        rm /etc/udev/rules.d/80-net-setup-link.rules
    fi
    /usr/bin/ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules
    if [[ '/etc/systemd/system/multi-user.target.wants/dhcpcd@eth0.service' ]]; then
        rm '/etc/systemd/system/multi-user.target.wants/dhcpcd@eth0.service'
    fi
    /usr/bin/ln -s '/usr/lib/systemd/system/dhcpcd@.service' '/etc/systemd/system/multi-user.target.wants/dhcpcd@eth0.service'
    /usr/bin/sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
    /usr/bin/systemctl enable sshd.service
    /usr/bin/pacman -S --noconfirm rng-tools
    /usr/bin/systemctl enable rngd

    echo -e "Configuring Vagrant specific settings..."
    /usr/bin/useradd --password $PASSWORD --comment 'Vagrant User' --create-home --user-group vagrant
    echo 'Defaults env_keep += "SSH_AUTH_SOCK"' > /etc/sudoers.d/10_vagrant
    echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/10_vagrant
    /usr/bin/chmod 0440 /etc/sudoers.d/10_vagrant
    /usr/bin/install --directory --owner=vagrant --group=vagrant --mode=0700 /home/vagrant/.ssh
    /usr/bin/curl --output /home/vagrant/.ssh/authorized_keys --location https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub
    /usr/bin/chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
    /usr/bin/chmod 0600 /home/vagrant/.ssh/authorized_keys

    echo -e "Cleaning up..."
    /usr/bin/pacman -Rcns --noconfirm gptfdisk
EOF

echo -e "Entering chroot to install..."
/usr/bin/arch-chroot $CHROOT_DIR /usr/local/bin/arch-config.sh
rm $CHROOT_DIR/usr/local/bin/arch-config.sh

echo -e "Completing installation and rebooting..."
/usr/bin/sleep 3
/usr/bin/umount $CHROOT_DIR
/usr/bin/systemctl reboot
