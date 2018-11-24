#!/bin/bash

set -e
set -x

# The below is only specific to Fedora 22 as of right now. All other later
# versions do not have issues with facter.
if [ -f /etc/os-release ]; then
    os_name="$(awk -F= '/^NAME/{ print $2 }' /etc/os-release | sed 's/"//g')"
    os_version_id="$(awk -F= '/^VERSION_ID/{ print $2}' /etc/os-release | sed 's/"//g')"
    if [[ $os_name = "Fedora" ]]; then
        if [[ $os_version_id = 22 ]]; then
            sudo dnf -y install facter ruby rubygems
        fi
        elif [[ $os_name = *openSUSE* ]]; then
        if [[ $os_version_id = *13.* ]]; then
            sudo zypper --non-interactive install https://ftp5.gwdg.de/pub/opensuse/discontinued/distribution/13.2/repo/oss/suse/x86_64/facter-2.0.2-2.2.1.x86_64.rpm
            elif [[ $os_version_id = *42.1* ]]; then
            sudo zypper --non-interactive install https://ftp5.gwdg.de/pub/opensuse/discontinued/distribution/leap/42.1/repo/oss/suse/x86_64/rubygem-facter-2.4.3-4.6.x86_64.rpm
            elif [[ $os_version_id = *42.2* ]]; then
            sudo zypper --non-interactive install https://ftp5.gwdg.de/pub/opensuse/discontinued/distribution/leap/42.2/repo/oss/suse/x86_64/rubygem-facter-2.4.6-7.1.x86_64.rpm
        fi
        elif [[ $os_name = *Oracle* ]]; then
        sudo yum -y install https://yum.oracle.com/repo/OracleLinux/OL7/developer_EPEL/x86_64/getPackage/facter-2.4.1-1.el7.x86_64.rpm
    fi
fi

codename="$(facter lsbdistcodename)"
os="$(facter operatingsystem)"
os_family="$(facter osfamily)"
os_release="$(facter operatingsystemrelease)"

if [[ $os_family = "Debian" || $os = "Debian" ]]; then
    # We need to cleanup for old repo update issues for hash mismatch
    if [[ $codename = "precise" ]]; then
        sudo apt-get clean
        sudo rm -r /var/lib/apt/lists/*
    fi
    if [[ $os_release > 6.0.10 ]]; then
        sudo apt-get update
        sudo apt-get install -y python-minimal linux-headers-$(uname -r) \
        build-essential zlib1g-dev libssl-dev libreadline-gplv2-dev unzip
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
    
    elif [[ $os_family = "RedHat" ]]; then
    if [[ $os != "Fedora" ]]; then
        sudo yum -y install python-devel
        
        elif [[ $os = "Fedora" ]]; then
        sudo dnf -y install python-devel python-dnf
    fi
    elif [[ $os_family = "Suse" ]]; then
    sudo zypper --non-interactive install python-devel
    elif [[ $os_family = "Linux" ]]; then
    if [[ $os = "Alpine" ]]; then
        chmod u+s /usr/bin/sudo
        apk add python alpine-sdk || true
    fi
    elif [[ $os_family = "Archlinux" ]]; then
    yes | sudo pacman -Syyu && yes | sudo pacman -S gc guile autoconf automake \
    binutils bison fakeroot file findutils flex gcc gettext grep \
    groff gzip libtool m4 make pacman patch pkgconf sed sudo systemd \
    texinfo util-linux which python-setuptools python-virtualenv python-pip \
    python-pyopenssl python2-setuptools python2-virtualenv python2-pip \
    python2-pyopenssl
fi