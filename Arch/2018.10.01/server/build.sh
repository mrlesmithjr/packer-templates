#! /usr/bin/env bash
packer build -var-file=../../../private_vars.json -var-file=box_info.json -var-file=20181001.json ../../arch-server.json