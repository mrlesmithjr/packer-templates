#! /usr/bin/env bash
packer build -only=virtualbox-iso -var-file=../../../private_vars.json -var-file=windows10.json ../../windows.json