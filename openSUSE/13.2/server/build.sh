#! /usr/bin/env bash
packer build -var-file=../../../private_vars.json -var-file=opensuse13-2.json ../../opensuse-server.json