#! /usr/bin/env bash
packer build -exclude=qemu -var-file=../../../private_vars.json -var-file=box_info.json -var-file=template.json ../../alpine-server.json
packer build -only=qemu -var-file=../../../private_vars.json -var-file=box_info.json -var-file=template.json ../../alpine-server.json