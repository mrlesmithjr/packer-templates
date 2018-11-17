#! /usr/bin/env bash
packer build -var-file=../../../private_vars.json -var-file=centos6.json ../../centos-server.json