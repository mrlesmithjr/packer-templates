#!/usr/bin/env bash

set -e
set -x

echo '==> Configuring sshd_config options'
echo '==> Turning off sshd DNS lookup to prevent timeout delay'
sudo bash -c "echo 'UseDNS no' >>/etc/ssh/sshd_config"
echo '==> Disablng GSSAPI authentication to prevent timeout delay'
sudo bash -c "echo 'GSSAPIAuthentication no' >>/etc/ssh/sshd_config"
