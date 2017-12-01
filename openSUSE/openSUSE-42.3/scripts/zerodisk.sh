# Zero out the free space to save space in the final image:
rm -rf /home/vagrant/*.sh
rm -rf /home/vagrant/.v*
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY
