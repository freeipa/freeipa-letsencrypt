#!/usr/bin/bash
set -o nounset -o errexit

WORKDIR=$(dirname "$(realpath $0)")

dnf install letsencrypt -y

ipa-cacert-manage install "$WORKDIR/ca/DSTRootCAX3.pem" -n DSTRootCAX3 -t C,,
ipa-certupdate -v

ipa-cacert-manage install "$WORKDIR/ca/LetsEncryptAuthorityX3.pem" -n letsencryptx3 -t C,,
ipa-certupdate -v

"$WORKDIR/renew-le.sh" --first-time
