#!/bin/bash

sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
#yum -y install epel-release
#yum -y install gcc make gcc-c++ kernel-devel.x86_64 perl wget
