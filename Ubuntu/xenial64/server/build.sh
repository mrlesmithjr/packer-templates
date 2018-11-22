#! /usr/bin/env bash
packer build -var-file=../../../private_vars.json -var-file=box_info.json -var-file=ubuntu1604.json ../../ubuntu-server.json