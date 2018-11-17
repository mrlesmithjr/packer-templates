#! /usr/bin/env bash
packer build -var-file=../../../private_vars.json -var-file=ubuntu1610.json ../../ubuntu-server.json