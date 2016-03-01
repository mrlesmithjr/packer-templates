packer-templates
----------------

This repository will be used for maintaining my personal Vagrant box build templates using Packer.  
https://www.packer.io/  

All of my builds are based on the VirtualBox provider.  
https://www.virtualbox.org/wiki/Downloads  

You can find the finalized builds over at Atlas and consume them as your needs dictate. All builds are base builds.

https://atlas.hashicorp.com/mrlesmithjr

Examples
-------

Replace boxname with one of the following builds:  
````
centos-6 - CentOS 6 x64
centos-7 - CentOS 7 x64
jessie64 - Debian 8 Jessie x64
precise64 - Ubuntu 12.04 Precise x64
trusty64 - Ubuntu 14.04 Trusty x64
utopic64 - Ubuntu 14.10 Utopic x64
vivid64 - Ubuntu 15.04 Vivid x64
wheezy64 - Debian 7 Wheezy x64
````
````
vagrant init mrlesmithjr/boxname
vagrant up
````
So for example, to spin up Ubuntu 14.04 x64
````
vagrant init mrlesmithjr/trusty64
vagrant up
````

License
-------

BSD

Author Information
------------------

Larry Smith Jr.
- @mrlesmithjr
- http://everythingshouldbevirtual.com
- mrlesmithjr [at] gmail.com
