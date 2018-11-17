#! /usr/bin/env bash
packer build -var-file=../../../private_vars.json -var-file=ubuntu1604.json ../../ubuntu-desktop.json