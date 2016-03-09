#
# postinstall.sh
#

date > /etc/vagrant_box_build_time

# remove zypper package locks
rm -f /etc/zypp/locks

# install required packages
#packages=( gcc make kernel-devel vim )
#zypper --non-interactive install --no-recommends --force-resolution ${packages[@]}

# install vagrant key
mkdir -pm 700 /home/vagrant/.ssh
curl -Lo /home/vagrant/.ssh/authorized_keys 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub'
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant: /home/vagrant/.ssh

# set vagrant sudo
printf "%b" "
# added by packer postinstall.sh
vagrant ALL=(ALL) NOPASSWD: ALL
" >> /etc/sudoers

# speed-up remote logins
printf "%b" "
# added by packer postinstall.sh
UseDNS no
" >> /etc/ssh/sshd_config

# disable gem docs
echo "gem: --no-ri --no-rdoc" >/etc/gemrc

# backlist i2c_piix4 - VirtualBox has no smbus
echo "blacklist i2c_piix4" > /etc/modprobe.d/100-blacklist-i2c_piix4.conf

# put shutdown command in path
ln -s /sbin/shutdown /usr/bin/shutdown

# ntp servers
printf "%b" "
# added by packer postinstall.sh
server 0.de.pool.ntp.org
server 1.de.pool.ntp.org
server 2.de.pool.ntp.org
server 3.de.pool.ntp.org
" >> /etc/ntp.conf

