#! /usr/bin/env bash
packer build -only=virtualbox-iso -var-file=ubuntu1810.json ../../ubuntu-desktop.json