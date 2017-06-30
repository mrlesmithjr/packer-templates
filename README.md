<!-- START doctoc generated TOC please keep comment here to allow auto update -->

<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

**Table of Contents**  _generated with [DocToc](https://github.com/thlorenz/doctoc)_

-   [packer-templates](#packer-templates)
    -   [Purpose](#purpose)
    -   [Information](#information)
        -   [Distros](#distros)
    -   [Requirements](#requirements)
        -   [Software](#software)
    -   [Usage](#usage)
        -   [Building a box](#building-a-box)
            -   [Select distro](#select-distro)
            -   [Build distro](#build-distro)
        -   [Testing a box](#testing-a-box)
            -   [Add box to Vagrant](#add-box-to-vagrant)
            -   [Create Vagrantfile](#create-vagrantfile)
            -   [Spin it up](#spin-it-up)
            -   [Test it out](#test-it-out)
            -   [Tear it down](#tear-it-down)
        -   [Cleaning up](#cleaning-up)
    -   [License](#license)
    -   [Author Information](#author-information)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# packer-templates

## Purpose

This repository is for maintaining my personal
[Vagrant Box Templates](https://github.com/mrlesmithjr/vagrant-box-templates)
using [Packer](https://www.packer.io).

## Information

-   All builds are based on the [VirtualBox](https://www.virtualbox.org) provider.

-   You can find my collection of builds [here](https://atlas.hashicorp.com/mrlesmithjr)

> NOTE: All builds are base builds and follow the Vagrant [guidelines](https://www.vagrantup.com/docs/boxes/base.html) of how a Vagrant
> box should be built.

### Distros

The following distros are available:

-   Centos
    -   6
    -   7
-   Debian
    -   Jessie
    -   Stretch
    -   Wheezy
-   Fedora
    -   22
    -   23
    -   24
    -   25
-   OpenSuse
    -   13.2
    -   42.1
-   RedHat
    -   7
-   Ubuntu
    -   Precise
    -   Trusty
    -   Utopic
    -   Vivid
    -   Wily
    -   Xenial
    -   Yakkety
    -   Zesty

## Requirements

### Software

-   [Packer](https://www.packer.io)
-   [Virtualbox](https://www.virtualbox.org)

## Usage

### Building a box

To build a [Vagrant](https://www.vagrantup.com) box with [Packer](https://packer.io)
for [Virtualbox](https://www.virtualbox.org):

#### Select distro

Choose which distro you are interested in building.

#### Build distro

> NOTE: This example we will have chosen Ubuntu Xenial

```bash
cd Ubuntu/xenial64
packer build template.json
```

Now watch your build kick off and run through the building process. Once it has
completed you will be ready to test it out.

### Testing a box

Once your build has completed you are ready to test it out.

#### Add box to Vagrant

```bash
cd Ubuntu/xenial64
vagrant box add xenial64 xenial-server-x86_64.box
```

#### Create Vagrantfile

```bash
cd ~
mkdir -p packer/vagrant/xenial64
cd packer/vagrant/xenial64
vagrant init xenial64
```

#### Spin it up

```bash
vagrant up
```

#### Test it out

```bash
vagrant ssh
```

Now do some basic tests to validate all is good.

#### Tear it down

```bash
vagrant destroy -f
```

### Cleaning up

Included in each distro is a cleanup script called `cleanup.sh` to clean up the
build folder when you are complete.

```bash
#!/bin/bash
rm *.box
rm -rf packer_cache
```

To cleanup:

```bash
cd Ubuntu/xenial64
./cleanup.sh
```

## License

MIT

## Author Information

Larry Smith Jr.

-   [@mrlesmithjr](https://www.twitter.com/mrlesmithjr)
-   [EverythingShouldBeVirtual](http://everythingshouldbevirtual.com)
-   mrlesmithjr [at] gmail.com
