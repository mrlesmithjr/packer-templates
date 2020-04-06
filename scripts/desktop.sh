#!/usr/bin/env bash

set -e
set -x

USERNAME=vagrant

if [ -f /etc/os-release ]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    id=$ID
    os_version_id=$VERSION_ID

elif [ -f /etc/redhat-release ]; then
    id="$(awk '{ print tolower($1) }' /etc/redhat-release | sed 's/"//g')"
    os_version_id="$(awk '{ print $3 }' /etc/redhat-release | sed 's/"//g' | awk -F. '{ print $1 }')"
fi

if [[ $id == "debian" ]]; then
    echo "==> Installing ubuntu-desktop"
    sudo apt-get install -y --no-install-recommends gnome-core xorg

    if [[ $os_version_id -lt 9 ]]; then
        GDM_CONFIG=/etc/gdm/daemon.conf
    else
        GDM_CONFIG=/etc/gdm3/daemon.conf
    fi

    sudo mkdir -p "$(dirname ${GDM_CONFIG})"
    sudo bash -c "echo "[daemon]" > $GDM_CONFIG"
    sudo bash -c "echo " # Enabling automatic login" >> $GDM_CONFIG"
    sudo bash -c "echo "AutomaticLoginEnable=True" >> $GDM_CONFIG"
    sudo bash -c "echo "AutomaticLogin=${USERNAME}" >> $GDM_CONFIG"
# LIGHTDM_CONFIG=/etc/lightdm/lightdm.conf
# echo "==> Configuring lightdm autologin"
# sudo bash -c "echo "[SeatDefaults]" >> $LIGHTDM_CONFIG"
# sudo bash -c "echo "autologin-user=${USERNAME}" >> $LIGHTDM_CONFIG"

elif [[ $id == "elementary" || $id == "linuxmint" ]]; then
    GDM_CUSTOM_CONFIG=/etc/gdm3/custom.conf
    LIGHTDM_CONFIG=/etc/lightdm/lightdm.conf

    echo "==> Configuring lightdm autologin"
    sudo bash -c "echo "[SeatDefaults]" >> $LIGHTDM_CONFIG"
    sudo bash -c "echo "autologin-user=${USERNAME}" >> $LIGHTDM_CONFIG"

    sudo mkdir -p "$(dirname ${GDM_CUSTOM_CONFIG})"
    sudo bash -c "echo "[daemon]" >> $GDM_CUSTOM_CONFIG"
    sudo bash -c "echo " # Enabling automatic login" >> $GDM_CUSTOM_CONFIG"
    sudo bash -c "echo "AutomaticLoginEnable=True" >> $GDM_CUSTOM_CONFIG"
    sudo bash -c "echo "AutomaticLogin=${USERNAME}" >> $GDM_CUSTOM_CONFIG"

elif [[ $id == "ubuntu" ]]; then
    echo "==> Installing ubuntu-desktop"
    sudo apt-get install -y --no-install-recommends ubuntu-desktop
    # Fixes issue with gnome-terminal starting
    sudo update-locale LANG="en_US.UTF-8" LANGUAGE

    if (($(echo $os_version_id '<' 17.04 | bc))); then
        GDM_CUSTOM_CONFIG=/etc/gdm/custom.conf
        LIGHTDM_CONFIG=/etc/lightdm/lightdm.conf
        echo "==> Configuring lightdm autologin"
        sudo bash -c "echo "[SeatDefaults]" >> $LIGHTDM_CONFIG"
        sudo bash -c "echo "autologin-user=${USERNAME}" >> $LIGHTDM_CONFIG"
        # Fix issue with Unity apps not showing up
        sudo apt-get install -y unity-lens-applications unity-lens-files
    else
        GDM_CUSTOM_CONFIG=/etc/gdm3/custom.conf
    fi

    sudo mkdir -p "$(dirname ${GDM_CUSTOM_CONFIG})"
    sudo bash -c "echo "[daemon]" >> $GDM_CUSTOM_CONFIG"
    sudo bash -c "echo " # Enabling automatic login" >> $GDM_CUSTOM_CONFIG"
    sudo bash -c "echo "AutomaticLoginEnable=True" >> $GDM_CUSTOM_CONFIG"
    sudo bash -c "echo "AutomaticLogin=${USERNAME}" >> $GDM_CUSTOM_CONFIG"

elif [[ $id == "centos" ]]; then
    if [[ $os_version_id -gt 6 && $os_version_id -lt 8 ]]; then
        sudo yum -y groupinstall "X Window System"
        sudo yum -y install gnome-classic-session gnome-terminal \
            nautilus-open-terminal control-center liberation-mono-fonts
        sudo ln -sf /lib/systemd/system/runlevel5.target /etc/systemd/system/default.target
    elif [[ $os_version_id -ge 8 ]]; then
        sudo yum -y update
        sudo yum -y group install "Server with GUI"
        sudo systemctl set-default graphical.target
    fi
    if [[ $os_version_id -gt 6 ]]; then
        GDM_CUSTOM_CONFIG=/etc/gdm/custom.conf
        sudo mkdir -p "$(dirname ${GDM_CUSTOM_CONFIG})"
        sudo bash -c "echo "[daemon]" > $GDM_CUSTOM_CONFIG"
        sudo bash -c "echo " # Enabling automatic login" >> $GDM_CUSTOM_CONFIG"
        sudo bash -c "echo "AutomaticLoginEnable=True" >> $GDM_CUSTOM_CONFIG"
        sudo bash -c "echo "AutomaticLogin=${USERNAME}" >> $GDM_CUSTOM_CONFIG"
    fi

elif [[ $id == "fedora" ]]; then
    sudo dnf -y groupinstall "Basic Desktop"
    sudo dnf -y install gnome-classic-session gnome-terminal \
        nautilus-open-terminal control-center liberation-mono-fonts
    sudo ln -sf /lib/systemd/system/runlevel5.target /etc/systemd/system/default.target
    GDM_CUSTOM_CONFIG=/etc/gdm/custom.conf
    sudo mkdir -p "$(dirname ${GDM_CUSTOM_CONFIG})"
    sudo bash -c "echo "[daemon]" > $GDM_CUSTOM_CONFIG"
    sudo bash -c "echo " # Enabling automatic login" >> $GDM_CUSTOM_CONFIG"
    sudo bash -c "echo "AutomaticLoginEnable=True" >> $GDM_CUSTOM_CONFIG"
    sudo bash -c "echo "AutomaticLogin=${USERNAME}" >> $GDM_CUSTOM_CONFIG"
    LIGHTDM_CONFIG=/etc/lightdm/lightdm.conf
    echo "==> Configuring lightdm autologin"
    sudo bash -c "echo "[SeatDefaults]" > $LIGHTDM_CONFIG"
    sudo bash -c "echo "autologin-user=${USERNAME}" >> $LIGHTDM_CONFIG"
fi

# We need to create artifact to trigger open-vm-tools-desktop install
if [ "$PACKER_BUILDER_TYPE" = "vmware-iso" ]; then
    sudo touch /etc/vmware_desktop

elif [ "$PACKER_BUILDER_TYPE" = "virtualbox-iso" ]; then
    sudo touch /etc/virtualbox_desktop
fi
