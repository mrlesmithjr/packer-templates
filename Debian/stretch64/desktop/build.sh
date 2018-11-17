#! /usr/bin/env bash
packer build -var-file=../../../private_vars.json -var-file=debian9.json ../../debian-desktop.json