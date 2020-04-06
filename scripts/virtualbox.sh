#!/usr/bin/env bash

set -x

if [ "$PACKER_BUILDER_TYPE" != "virtualbox-iso" ]; then
    exit 0
fi

if [ -f /etc/os-release ]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    id=$ID
    os_version_id=$VERSION_ID

elif [ -f /etc/redhat-release ]; then
    id="$(awk '{ print tolower($1) }' /etc/redhat-release | sed 's/"//g')"
    os_version_id="$(awk '{ print $3 }' /etc/redhat-release | sed 's/"//g' | awk -F. '{ print $1 }')"
fi

if [[ $id == "ol" ]]; then
    os_version_id_short="$(echo $os_version_id | cut -f1 -d".")"
else
    os_version_id_short="$(echo $os_version_id | cut -f1-2 -d".")"
fi

if [[ $id == "alpine" ]]; then
    echo http://dl-cdn.alpinelinux.org/alpine/edge/community >>/etc/apk/repositories
    apk update
    if (($(echo $os_version_id_short '==' 3.7 | bc))); then
        apk add -U virtualbox-guest-additions virtualbox-guest-modules-virthardened || true
    else
        apk add -U virtualbox-guest-additions virtualbox-guest-modules-virt || true
    fi
    echo vboxsf >>/etc/modules
    apk add nfs-utils || true
    rc-update add rpc.statd
    rc-update add nfsmount

elif [[ $id == "arch" ]]; then
    sudo /usr/bin/pacman -S --noconfirm linux-headers virtualbox-guest-utils virtualbox-guest-modules-arch nfs-utils
    sudo bash -c "echo -e 'vboxguest\nvboxsf\nvboxvideo' > /etc/modules-load.d/virtualbox.conf"
    sudo /usr/bin/systemctl enable vboxservice.service
    sudo /usr/bin/systemctl enable rpcbind.service
    sudo /usr/bin/usermod --append --groups vagrant,vboxsf vagrant

elif [[ $id == "centos" || $id == "ol" ]]; then
    sudo yum -y install gcc kernel-devel-"$(uname -r)" kernel-headers-"$(uname -r)" dkms make bzip2 perl &&
        sudo yum -y groupinstall "Development Tools"
    if [[ $id == "ol" ]]; then
        sudo yum -y install elfutils-libelf-devel
        if [[ $os_version_id_short -eq 7 ]]; then
            sudo yum -y install kernel-devel kernel-headers dkms
        fi
    fi

elif [[ $id == "debian" || $id == "linuxmint" || $id == "ubuntu" ]]; then
    if [ -f /etc/virtualbox_desktop ]; then
        sudo apt-get install -y xserver-xorg-video-vmware
    fi

elif [[ $id == "fedora" ]]; then
    sudo dnf -y install gcc kernel-devel-"$(uname -r)" kernel-headers-"$(uname -r)" dkms make bzip2 perl &&
        sudo dnf -y groupinstall "Development Tools"
    if [[ $os_version_id -ge 28 ]]; then
        sudo dnf -y remove virtualbox-guest-additions
    fi

elif [[ $id == "opensuse" || $id == "opensuse-leap" ]]; then
    sudo zypper --non-interactive install gcc kernel-devel \
        make bzip2 perl
fi

if [[ $id != "alpine" && $id != "arch" ]]; then
    if [[ -f /home/vagrant/VBoxGuestAdditions.iso ]]; then
        vbox_guest_additions_path="/home/vagrant/VBoxGuestAdditions.iso"

    elif [[ -f /root/VBoxGuestAdditions.iso ]]; then
        vbox_guest_additions_path="/root/VBoxGuestAdditions.iso"
    fi
    sudo mkdir -p /mnt/virtualbox
    sudo mount -o loop "$vbox_guest_additions_path" /mnt/virtualbox
    sudo sh /mnt/virtualbox/VBoxLinuxAdditions.run
    if [[ $id == "ol" ]]; then
        sudo /sbin/rcvboxadd quicksetup all
    fi
    sudo umount /mnt/virtualbox
    sudo rm -rf "$vbox_guest_additions_path"
fi

if [ -f /home/vagrant/VBoxGuestAdditions.iso ]; then
    sudo rm -rf /home/vagrant/VBoxGuestAdditions.iso
elif [ -f /root/VBoxGuestAdditions.iso ]; then
    sudo rm -rf /root/VBoxGuestAdditions.iso
fi
