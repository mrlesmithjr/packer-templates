#! /usr/bin/env bash
packer build -var-file=../../../private_vars.json -var-file=ol7.json ../../ol-server.json