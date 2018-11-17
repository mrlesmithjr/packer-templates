#! /usr/bin/env bash
packer build -var-file=../../../private_vars.json -var-file=fedora29.json ../../fedora-desktop.json