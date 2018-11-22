# packer-templates

<!-- TOC -->autoauto- [packer-templates](#packer-templates)auto    - [Purpose](#purpose)auto    - [Information](#information)auto    - [Requirements](#requirements)auto        - [Software](#software)auto    - [Usage](#usage)auto        - [Building a box](#building-a-box)auto            - [Select distro](#select-distro)auto            - [Build distro](#build-distro)auto        - [Testing a box](#testing-a-box)auto            - [Add box to Vagrant](#add-box-to-vagrant)auto            - [Create Vagrantfile](#create-vagrantfile)auto            - [Spin it up](#spin-it-up)auto            - [Test it out](#test-it-out)auto            - [Tear it down](#tear-it-down)auto        - [Cleaning up](#cleaning-up)auto        - [Using pre-built and ready for consumption Vagrant templates](#using-pre-built-and-ready-for-consumption-vagrant-templates)auto    - [License](#license)auto    - [Author Information](#author-information)autoauto<!-- /TOC -->

## Purpose

This repository is for maintaining my personal
[Vagrant Box Templates](https://github.com/mrlesmithjr/vagrant-box-templates)
using [Packer](https://www.packer.io).

## Information

All builds are based on the following providers:

- [virtualbox](https://www.virtualbox.org)
- [vmware_desktop](https://www.vmware.com)

- You can find my collection of builds [here](https://app.vagrantup.com/mrlesmithjr)

> NOTE: All builds are base builds and follow the Vagrant [guidelines](https://www.vagrantup.com/docs/boxes/base.html) of how a Vagrant
> box should be built.

## Requirements

All of my Packer templates are configured to upload to Vagrant Cloud after a successful build has been executed. In order to upload a box version to Vagrant Cloud, you will need to create a `private_vars.json` file in the root of this repo with the following info:

```json
{
  "vagrant_cloud_token": "Your Vagrant Cloud private API token",
  "username": "Your Vagrant Cloud username"
}
```

If you do not want this functionality, you will need to edit the respective template within the distro folder and remove the following:

```json
{
  "type": "vagrant-cloud",
  "box_tag": "{{ user `box_tag` }}",
  "access_token": "{{ user `vagrant_cloud_token` }}",
  "version": "{{ timestamp }}"
}
```

### Software

- [Packer](https://www.packer.io)
- [Virtualbox](https://www.virtualbox.org)

## Usage

### Building a box

To build a [Vagrant](https://www.vagrantup.com) box with [Packer](https://packer.io)
for [Virtualbox](https://www.virtualbox.org):

#### Select distro

Choose which distro you are interested in building.

#### Build distro

> NOTE: This example we will have chosen Ubuntu Xenial

```bash
cd Ubuntu/xenial64/server
packer build -var-file=../../../private_vars.json -var-file=ubuntu1604.json ../../ubuntu-server.json
```

Now watch your build kick off and run through the building process. Once it has
completed you will be ready to test it out.

### Testing a box

Once your build has completed you are ready to test it out.

#### Add box to Vagrant

> Note: The number at the end is the epoch time of the build. Replace this accordingly.

```bash
cd Ubuntu/xenial64/server
vagrant box add xenial64-server-packer-template-virtualbox-1542509766 xenial64-server-packer-template-virtualbox-1542509766.box
```

#### Create Vagrantfile

```bash
cd ~
mkdir -p packer/vagrant/xenial64-server
cd packer/vagrant/xenial64-server
vagrant init xenial64-server-packer-template-virtualbox-1542509766
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

When you need to clean up any of the lingering files/folers generated during
building, you can execute the [cleanup_builds.sh](cleanup_builds.sh) script.

### Using pre-built and ready for consumption Vagrant templates

The majority of these templates are used to populate my [vagrant-box-templates](https://github.com/mrlesmithjr/vagrant-box-templates) repo. I would highly
recommend leveraging this repo for testing and etc.

## License

MIT

## Author Information

Larry Smith Jr.

- [@mrlesmithjr](https://www.twitter.com/mrlesmithjr)
- [EverythingShouldBeVirtual](http://everythingshouldbevirtual.com)
- [mrlesmithjr@gmail.com](mailto:mrlesmithjr@gmail.com)
