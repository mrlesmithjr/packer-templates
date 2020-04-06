#!/usr/bin/env bash

set -e
set -x

curl -X POST \
    -u $SSH_USER:$SSH_PASS \
    http://localhost/api/v1.0/storage/volume/ \
    -H 'Content-Type: application/json' \
    -d '{
    "volume_name": "tank",
    "layout": [
        {
            "vdevtype": "stripe",
            "disks": [
                "da1"
            ]
        }
    ]
}'

curl -X POST \
    -u $SSH_USER:$SSH_PASS \
    http://localhost/api/v1.0/storage/volume/tank/datasets/ \
    -H 'Content-Type: application/json' \
    -d '{
    "name": "vagrant"
}'

curl -X POST \
    -u $SSH_USER:$SSH_PASS \
    http://localhost/api/v1.0/account/users/ \
    -H 'Content-Type: application/json' \
    -d '{
   "bsdusr_username": "vagrant",
   "bsdusr_creategroup": true,
   "bsdusr_full_name": "Vagrant User",
   "bsdusr_password": "vagrant",
   "bsdusr_uid": 1001,
   "bsdusr_home": "/mnt/tank/vagrant",
   "bsdusr_shell": "/usr/local/bin/zsh",
   "bsdusr_sshpubkey": "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key",
   "bsdusr_sudo": true
}'

# if [ "$PACKER_BUILDER_TYPE" == "vmware-iso" ]; then
#     pkg install --yes open-vm-tools-nox11
# fi
