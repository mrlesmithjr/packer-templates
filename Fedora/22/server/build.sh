#! /usr/bin/env bash
packer build -var-file=../../../private_vars.json -var-file=fedora22.json ../../fedora-server.json