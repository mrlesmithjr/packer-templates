#! /usr/bin/env bash
packer build -var-file=../../../private_vars.json -var-file=centos7.json ../../centos-desktop.json