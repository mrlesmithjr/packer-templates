#! /usr/bin/env bash
packer build -only=virtualbox-iso -var-file=linuxmint19.json ../../linuxmint-desktop.json