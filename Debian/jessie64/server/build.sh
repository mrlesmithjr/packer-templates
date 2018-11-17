#! /usr/bin/env bash
packer build -var-file=../../../private_vars.json -var-file=debian8.json ../../debian-server.json