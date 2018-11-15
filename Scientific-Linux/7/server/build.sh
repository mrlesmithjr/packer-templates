#! /usr/bin/env bash
packer build -only=virtualbox-iso -var-file=sl-7.json ../../sl-server.json