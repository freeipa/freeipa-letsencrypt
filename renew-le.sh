#!/usr/bin/bash
set -o nounset -o errexit

WORKDIR=$(dirname "$(realpath $0)")
EMAIL=""

### cron
# skip renewal if the cert is still valid for more than 30 days
# comment out this line for the first run
if [ "${1:-renew}" != "--first-time" ]
then
	end_timestamp=`date +%s --date="$(openssl x509 -enddate -noout -in /var/lib/ipa/certs/httpd.crt | cut -d= -f2)"`
	now_timestamp=`date +%s`
	let diff=($end_timestamp-$now_timestamp)/86400
	if [ "$diff" -gt "30" ]; then
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
openssl req -new -sha256 -config "$WORKDIR/ipa-httpd.cnf" -key /var/lib/ipa/private/httpd.key -out "$WORKDIR/httpd-csr.der" $OPENSSL_EXTRA_ARGS

# httpd process prevents letsencrypt from working, stop it
if ! command -v service >/dev/null 2>&1; then
	systemctl stop httpd
else
	service httpd stop
fi

# get a new cert
letsencrypt certonly --standalone --csr "$WORKDIR/httpd-csr.der" --email "$EMAIL" --agree-tos

# replace the cert
cp /var/lib/ipa/certs/httpd.crt /var/lib/ipa/certs/httpd.crt.bkp
mv -f "$WORKDIR/0000_cert.pem" /var/lib/ipa/certs/httpd.crt
restorecon -v /var/lib/ipa/certs/httpd.crt

# start httpd with the new cert
if ! command -v service >/dev/null 2>&1; then
	systemctl start httpd
else
	service httpd start
fi
