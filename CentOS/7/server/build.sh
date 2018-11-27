#! /usr/bin/env bash
packer build -var-file=../../../private_vars.json -var-file=template.json ../../centos-server.json