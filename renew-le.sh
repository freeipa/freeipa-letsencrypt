#!/usr/bin/bash
set -o nounset -o errexit

WORKDIR="/root/ipa-le"
EMAIL=""
#cd "$WORKDIR"

### cron
# check that the cert will last at least 2 days from now to prevent too frequent renewal
# comment out this line for the first run
if [ "${1:-renew}" != "--first-time" ]
then
	certutil -d /etc/httpd/alias/ -V -u V -n Server-Cert -b "$(date '+%y%m%d%H%M%S%z' --date='2 days')" && exit 0
fi

# cert renewal is needed if we reached this line

# cleanup
rm -f "$WORKDIR"/*.pem
rm -f "$WORKDIR"/httpd-csr.*

# generate CSR
certutil -R -d /etc/httpd/alias/ -k Server-Cert -f /etc/httpd/alias/pwdfile.txt -s "CN=$(hostname -f)" --extSAN "dns:$(hostname -f)" -o "$WORKDIR/httpd-csr.der"

# httpd process prevents letsencrypt from working, stop it
service httpd stop

# get a new cert
letsencrypt certonly --standalone --csr "$WORKDIR/httpd-csr.der" --email "$EMAIL" --agree-tos

# remove old cert
certutil -D -d /etc/httpd/alias/ -n Server-Cert
# add the new cert
certutil -A -d /etc/httpd/alias/ -n Server-Cert -t u,u,u -a -i "$WORKDIR/0000_cert.pem"

# start httpd with the new cert
service httpd start
