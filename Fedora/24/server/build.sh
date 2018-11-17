#! /usr/bin/env bash
packer build -var-file=../../../private_vars.json -var-file=fedora24.json ../../fedora-server.json