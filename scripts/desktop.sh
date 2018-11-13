#!/bin/bash
set -e
set -x

if [ -f /etc/debian_version ]; then
    os="$(facter operatingsystem)"
    os_release="$(facter operatingsystemrelease)"
    if [[ $os == "Ubuntu" ]]; then
        echo "==> Installing ubuntu-desktop"
        sudo apt-get install -y --no-install-recommends ubuntu-desktop
        
        USERNAME=vagrant
        if [[ $os_release < 18.04  ]]; then
            GDM_CUSTOM_CONFIG=/etc/gdm/custom.conf
            LIGHTDM_CONFIG=/etc/lightdm/lightdm.conf
            
            echo "==> Configuring lightdm autologin"
            sudo bash -c "echo "[SeatDefaults]" >> $LIGHTDM_CONFIG"
            sudo bash -c "echo "autologin-user=${USERNAME}" >> $LIGHTDM_CONFIG"
        else
            GDM_CUSTOM_CONFIG=/etc/gdm3/custom.conf
        fi
        
        echo "==> Configuring lightdm autologin"
        sudo mkdir -p "$(dirname ${GDM_CUSTOM_CONFIG})"
        sudo bash -c "echo "[daemon]" >> $GDM_CUSTOM_CONFIG"
        sudo bash -c "echo "# Enabling automatic login" >> $GDM_CUSTOM_CONFIG"
        sudo bash -c "echo "AutomaticLoginEnable=True" >> $GDM_CUSTOM_CONFIG"
        sudo bash -c "echo "AutomaticLogin=${USERNAME}" >> $GDM_CUSTOM_CONFIG"
    fi
fi