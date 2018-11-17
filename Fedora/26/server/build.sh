#! /usr/bin/env bash
packer build -var-file=../../../private_vars.json -var-file=fedora26.json ../../fedora-server.json