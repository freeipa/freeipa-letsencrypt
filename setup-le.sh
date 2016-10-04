#!/usr/bin/bash
set -o nounset -o errexit

# do this once before taking snapshot of the VM
dnf install letsencrypt -y

ipa-cacert-manage install /root/ca/DSTRootCAX3.pem -n DSTRootCAX3 -t ,,
ipa-certupdate -v

# this command might blow up, Honza knows a workaround - it is a bug :-)
ipa-cacert-manage install /root/ca/LetsEncryptAuthorityX1.pem -n letsencrypt -t C,,
ipa-certupdate -v

