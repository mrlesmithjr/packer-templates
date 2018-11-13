#!/bin/bash
set -e
set -x

if [ -f /etc/debian_version ]; then
    os="$(facter operatingsystem)"
    if [[ $os == "Ubuntu" ]]; then
        echo "==> Installing ubuntu-desktop"
        apt-get install -y --no-install-recommends ubuntu-desktop

        USERNAME=vagrant
        GDM_CUSTOM_CONFIG=/etc/gdm3/custom.conf

        mkdir -p "$(dirname ${GDM_CUSTOM_CONFIG})"
        echo "[daemon]" >> $GDM_CUSTOM_CONFIG
        echo "# Enabling automatic login" >> $GDM_CUSTOM_CONFIG
        echo "AutomaticLoginEnable=True" >> $GDM_CUSTOM_CONFIG
        echo "AutomaticLogin=${USERNAME}" >> $GDM_CUSTOM_CONFIG
    fi
fi