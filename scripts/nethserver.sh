#!/usr/bin/env bash
set -e
sudo yum install -y http://mirror.nethserver.org/nethserver/nethserver-release-7.rpm
sudo nethserver-install
