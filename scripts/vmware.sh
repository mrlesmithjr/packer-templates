#!/usr/bin/env bash

set -e
set -x

if [ "$PACKER_BUILDER_TYPE" != "vmware-iso" ]; then
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
    apk add open-vm-tools || true
    rc-update add open-vm-tools default
    modprobe fuse
    echo "fuse" >>/etc/modules
    mkdir -p /mnt/hgfs
    echo "vmhgfs-fuse /mnt/hgfs fuse defaults,allow_other 0 0" >>/etc/fstab

elif [[ $id == "arch" ]]; then
    sudo /usr/bin/pacman -S --noconfirm linux-headers open-vm-tools nfs-utils
    sudo /usr/bin/systemctl enable vmtoolsd.service
    sudo /usr/bin/systemctl enable rpcbind.service

elif [[ $id == "debian" || $id == "elementary" || $id == "linuxmint" || $id == "ubuntu" ]]; then
    if [ -f /etc/vmware_desktop ]; then
        sudo apt-get install -y open-vm-tools-desktop
    else
        sudo apt-get install -y open-vm-tools
    fi
    if [[ $id == "ubuntu" ]]; then
        if (($(echo $os_version_id '>=' 18.04 | bc))); then
            # This is the fix for https://kb.vmware.com/s/article/56409
            sudo bash -c "sed -i '2iAfter=dbus.service' /lib/systemd/system/open-vm-tools.service"
        fi
    fi

elif [[ $id == "centos" || $id == "ol" ]]; then
    if [[ $os_version_id_short -ge 6 ]]; then
        if [ -f /etc/vmware_desktop ]; then
            sudo yum -y install open-vm-tools-desktop
        else
            sudo yum -y install open-vm-tools
        fi
    elif [[ $os_version_id_short -eq 5 ]]; then
        export PATH=$PATH:/sbin
        sudo yum -y install net-tools perl
        sudo mkdir -p /mnt/vmware
        sudo mount -o loop /home/vagrant/linux.iso /mnt/vmware
        cd /tmp
        cp /mnt/vmware/VMwareTools-*.gz .
        tar zxvf VMwareTools-*.gz
        sudo ./vmware-tools-distrib/vmware-install.pl --default
        sudo umount /mnt/vmware
        sudo rm -rf /home/vagrant/linux.iso
    fi
    if [[ $os_version_id_short -ge 7 ]]; then
        sudo /bin/systemctl restart vmtoolsd.service
    elif [[ $os_version_id_short -eq 6 ]]; then
        sudo service vmtoolsd restart
    fi

elif [[ $id == "fedora" ]]; then
    if [ -f /etc/vmware_desktop ]; then
        sudo dnf -y install open-vm-tools-desktop
    else
        sudo dnf -y install open-vm-tools
    fi
    sudo /bin/systemctl restart vmtoolsd.service

elif [[ $id == "opensuse" || $id == "opensuse-leap" ]]; then
    sudo zypper --non-interactive install open-vm-tools
fi
