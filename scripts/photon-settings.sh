#!/bin/bash -eux

##
## Misc configuration
##

#echo '> Disable IPv6'
#echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
#echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
#sysctl -p

echo '> Applying latest Updates...'
tdnf -y update

echo '> Installing Additional Packages...'
tdnf install -y \
  less \
  nano \
  logrotate \
  curl \
  wget \
  unzip \
  awk \
  tar \
  powershell

echo '> Unset Machine-ID to generate unique ID when OVA is deployed.  This will provide each deployed appliance with a unique DHCP ID.'
echo -n > /etc/machine-id

echo '> Done'
