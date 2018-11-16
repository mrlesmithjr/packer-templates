#! /usr/bin/env bash
packer build -only=virtualbox-iso -var-file=linuxmint18.json ../../linuxmint-desktop.json