#! /usr/bin/env bash
packer build -var-file=../../../private_vars.json -var-file=ubuntu1704.json ../../ubuntu-desktop.json