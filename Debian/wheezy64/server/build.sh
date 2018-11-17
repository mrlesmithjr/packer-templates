#! /usr/bin/env bash
packer build -var-file=../../../private_vars.json -var-file=debian7.json ../../debian-server.json