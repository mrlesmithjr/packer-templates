## packer-templates

This repository is for maintaining my personal Vagrant box build templates
using [Packer].

All of my builds are based on the [VirtualBox] provider.

You can find my collection of builds [here](https://atlas.hashicorp.com/mrlesmithjr)

> NOTE: All builds are base builds.

## Examples

Replace boxname with one of the following builds:

| BoxName   | Distro                   |
| --------- | ------------------------ |
| centos-6  | CentOS 6 x64             |
| centos-7  | CentOS 7 x64             |
| fedora-24 | Fedora 24 x64            |
| fedora-25 | Fedora 25 x64            |
| wheezy64  | Debian 7 Wheezy x64      |
| jessie64  | Debian 8 Jessie x64      |
| precise64 | Ubuntu 12.04 Precise x64 |
| trusty64  | Ubuntu 14.04 Trusty x64  |
| utopic64  | Ubuntu 15.04 Vivid x64   |
| xenial64  | Ubuntu 16.04 Xenial x64  |

```bash
    vagrant init mrlesmithjr/boxname
    vagrant up
```

So for example, to spin up `Ubuntu 14.04 x64`:

```bash
    vagrant init mrlesmithjr/trusty64
    vagrant up
```

## License

BSD

## Author Information

Larry Smith Jr.

-   [@mrlesmithjr]
-   <http://everythingshouldbevirtual.com>
-   mrlesmithjr [at] gmail.com

[@mrlesmithjr]: https://www.twitter.com/mrlesmithjr

[packer]: https://www.packer.io/

[virtualbox]: https://www.virtualbox.org/wiki/Downloads
