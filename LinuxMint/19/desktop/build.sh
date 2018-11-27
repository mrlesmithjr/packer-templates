#! /usr/bin/env bash
packer build -var-file=../../../private_vars.json -var-file=box_info.json -only=virtualbox-iso -var-file=template.json ../../linuxmint-desktop.json