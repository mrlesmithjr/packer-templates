#! /usr/bin/env bash
packer build -only=virtualbox-iso -var-file=../../../private_vars.json -var-file=box_info.json -var-file=sl-7.json ../../sl-server.json