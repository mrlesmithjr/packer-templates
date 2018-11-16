#! /usr/bin/env bash
find . -type d -name "output-*"
find . -type d -name "output-*" -exec rm -rf {} +
find . -type d -name "packer_cache"
find . -type d -name "packer_cache" -exec rm -rf {} +
find . -type f -name "*.box"
find . -type f -name "*.box" -exec rm {} +
find . -type f -name "*.iso"
find . -type f -name "cleanup.sh" ! -path '*scripts/*' -exec git rm {} +
find . -type f -name "template.json"
find . -type f -name "Vagrantfile"
find . -type f -name "Vagrantfile" -exec rm {} +