#!/usr/bin/env bash

set -e
set -x

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
    chmod u+s /usr/bin/sudo
    apk add python alpine-sdk || true

elif [[ $id == "arch" ]]; then
    yes | sudo pacman -Syyu && yes | sudo pacman -S gc guile autoconf automake \
        binutils bison fakeroot file findutils flex gcc gettext grep \
        groff gzip libtool m4 make pacman patch pkgconf sed sudo systemd \
        texinfo util-linux which python-setuptools python-virtualenv python-pip \
        python-pyopenssl python2-setuptools python2-virtualenv python2-pip \
        python2-pyopenssl

elif [[ $id == "centos" || $id == "ol" ]]; then
    if [[ $os_version_id_short -eq 5 ]]; then
        for F in /etc/yum.repos.d/*.repo; do
            sudo bash -c "echo '# EOL DISTRO' > $F"
        done
        cat <<_EOF_ | sudo bash -c "cat > /etc/yum.repos.d/Vault.repo"
[base]
name=CentOS-5.11 - Base
baseurl=http://vault.centos.org/5.11/os/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5
enabled=1
[updates]
name=CentOS-5.11 - Updates
baseurl=http://vault.centos.org/5.11/updates/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5
enabled=1
[extras]
name=CentOS-5.11 - Extras
baseurl=http://vault.centos.org/5.11/extras/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5
enabled=1
[centosplus]
name=CentOS-5.11 - Plus
baseurl=http://vault.centos.org/5.11/centosplus/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5
enabled=1
_EOF_
    fi

    if [[ $id != "ol" ]]; then
        sudo yum -y install epel-release
    else
        if [[ $os_version_id_short -eq 7 ]]; then
            sudo rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

        elif [[ $os_version_id_short -eq 8 ]]; then
            sudo rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
        fi
    fi

    if [[ $os_version_id_short -lt 8 ]]; then
        sudo yum -y install cloud-utils-growpart python-devel
    else
        sudo yum -y install cloud-utils-growpart platform-python-devel
    fi

elif [[ $id == "debian" ]]; then
    sudo apt-get update
    echo "libc6:amd64     libraries/restart-without-asking        boolean true" | sudo debconf-set-selections
    echo "libssl1.1:amd64 libssl1.1/restart-services      string" | sudo debconf-set-selections
    sudo apt-get install -y python-minimal linux-headers-"$(uname -r)" \
        build-essential zlib1g-dev libssl-dev libreadline-gplv2-dev unzip

    if [[ ! -f /etc/vyos_build ]]; then
        if [[ $os_version_id -gt 7 ]]; then
            sudo apt-get -y install cloud-initramfs-growroot
        fi
    fi

elif [[ $id == "elementary" ]]; then
    sudo apt-get update
    echo "libc6:amd64     libraries/restart-without-asking        boolean true" | sudo debconf-set-selections
    echo "libssl1.1:amd64 libssl1.1/restart-services      string" | sudo debconf-set-selections
    sudo apt-get install -y python-minimal linux-headers-"$(uname -r)" \
        build-essential zlib1g-dev libssl-dev libreadline-gplv2-dev unzip

    if [[ ! -f /etc/vyos_build ]]; then
        if [[ $os_version_id -gt 7 ]]; then
            sudo apt-get -y install cloud-initramfs-growroot
        fi
    fi

elif [[ $id == "fedora" ]]; then
    if [[ $os_version_id -lt 30 ]]; then
        sudo dnf -y install python-devel python-dnf
    else
        sudo dnf -y install initscripts python-devel python3-dnf
    fi

elif [[ $id == "linuxmint" ]]; then
    sudo apt-get update
    echo "libc6:amd64     libraries/restart-without-asking        boolean true" | sudo debconf-set-selections
    echo "libssl1.1:amd64 libssl1.1/restart-services      string" | sudo debconf-set-selections
    sudo apt-get install -y python-minimal linux-headers-"$(uname -r)" \
        build-essential zlib1g-dev libssl-dev libreadline-gplv2-dev unzip

    if [[ ! -f /etc/vyos_build ]]; then
        if [[ $os_version_id -gt 7 ]]; then
            sudo apt-get -y install cloud-initramfs-growroot
        fi
    fi

elif [[ $id == "opensuse" || $id == "opensuse-leap" ]]; then
    sudo zypper --non-interactive install python-devel

elif [[ $id == "ubuntu" ]]; then
    if (($(echo $os_version_id '==' 12.04 | bc))); then
        sudo apt-get clean
        sudo rm -r /var/lib/apt/lists/*
    fi
    sudo apt-get update
    echo "libc6:amd64     libraries/restart-without-asking        boolean true" | sudo debconf-set-selections
    echo "libssl1.1:amd64 libssl1.1/restart-services      string" | sudo debconf-set-selections
    if [[ $os_version_id_short -lt 20.04 ]]; then
        sudo apt-get install -y python-minimal
    fi
    sudo apt-get install -y linux-headers-"$(uname -r)" \
        build-essential zlib1g-dev libssl-dev libreadline-gplv2-dev unzip
    if [[ ! -f /etc/vyos_build ]]; then
        sudo apt-get -y install cloud-initramfs-growroot
    fi
fi

if [[ $id == "debian" || $id == "elementary" || $id == "linuxmint" || $id == "ubuntu" ]]; then
    if [[ $id == "elementary" || $id == "linuxmint" ]]; then
        # Remove /etc/rc.local used for provisioning
        sudo rm /etc/rc.local
        if [ -f /etc/rc.local.orig ]; then
            sudo mv /etc/rc.local.orig /etc/rc.local
        fi
    fi

    # Check for /etc/rc.local and create if needed. This has been depricated in
    # Debian 9 and later. So we need to resolve this in order to regenerate SSH host
    # keys.
    if [ ! -f /etc/rc.local ]; then
        sudo bash -c "echo '#!/bin/sh -e' > /etc/rc.local"
        sudo bash -c "echo 'test -f /etc/ssh/ssh_host_dsa_key || dpkg-reconfigure openssh-server' >> /etc/rc.local"
        sudo bash -c "echo 'exit 0' >> /etc/rc.local"
        sudo chmod +x /etc/rc.local
        sudo systemctl daemon-reload
        sudo systemctl enable rc-local
        sudo systemctl start rc-local
    else
        sudo bash -c "sed -i -e 's|exit 0||' /etc/rc.local"
        sudo bash -c "sed -i -e 's|.*test -f /etc/ssh/ssh_host_dsa_key.*||' /etc/rc.local"
        sudo bash -c "echo 'test -f /etc/ssh/ssh_host_dsa_key || dpkg-reconfigure openssh-server' >> /etc/rc.local"
        sudo bash -c "echo 'exit 0' >> /etc/rc.local"
    fi
fi

# Fix machine-id issue with duplicate IP addresses being assigned
if [ -f /etc/machine-id ]; then
    sudo truncate -s 0 /etc/machine-id
fi
