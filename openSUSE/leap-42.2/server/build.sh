#! /usr/bin/env bash
packer build -only=virtualbox-iso -var-file=../../../private_vars.json -var-file=box_info.json -var-file=leap422.json ../../opensuse-server.json