#!/usr/bin/bash
set -o nounset -o errexit

WORKDIR=$(dirname "$(realpath $0)")
EMAIL=""

### cron
# check that the cert will last at least 2 days from now to prevent too frequent renewal
# comment out this line for the first run
if [ "${1:-renew}" != "--first-time" ]
then
	start_timestamp=`date +%s --date="$(openssl x509 -startdate -noout -in /var/lib/ipa/certs/httpd.crt | cut -d= -f2)"`
	now_timestamp=`date +%s`
	let diff=($now_timestamp-$start_timestamp)/86400
	if [ "$diff" -lt "2" ]; then
		exit 0
	fi
fi
cd "$WORKDIR"
# cert renewal is needed if we reached this line

# cleanup
rm -f "$WORKDIR"/*.pem
rm -f "$WORKDIR"/httpd-csr.*

# generate CSR
OPENSSL_PASSWD_FILE="/var/lib/ipa/passwds/$HOSTNAME-443-RSA"
[ -f "$OPENSSL_PASSWD_FILE" ] && OPENSSL_EXTRA_ARGS="-passin file:$OPENSSL_PASSWD_FILE" || OPENSSL_EXTRA_ARGS=""
openssl req -new -sha256 -config "$WORKDIR/ipa-httpd.cnf"  -key /var/lib/ipa/private/httpd.key -out "$WORKDIR/httpd-csr.der" $OPENSSL_EXTRA_ARGS

# httpd process prevents letsencrypt from working, stop it
service httpd stop

# get a new cert
letsencrypt certonly --standalone --csr "$WORKDIR/httpd-csr.der" --email "$EMAIL" --agree-tos

# replace the cert
cp /var/lib/ipa/certs/httpd.crt /var/lib/ipa/certs/httpd.crt.bkp
mv -f "$WORKDIR/0000_cert.pem" /var/lib/ipa/certs/httpd.crt
restorecon -v /var/lib/ipa/certs/httpd.crt

# start httpd with the new cert
service httpd start
