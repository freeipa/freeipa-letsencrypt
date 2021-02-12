#!/usr/bin/bash
set -o nounset -o errexit

WORKDIR=$(dirname "$(realpath $0)")
EMAIL=""

# This is needed for enabling the certificates
# TODO : Store safely
DIRPASSWD=""

### cron
# check that the cert will last at least 2 days from now to prevent too frequent renewal
# comment out this line for the first run
if [ "${1:-renew}" != "--first-time" ]
then
        echo "Checking when certificate was renewed"
        start_timestamp=`date +%s --date="$(openssl x509 -startdate -noout -in /var/lib/ipa/certs/httpd.crt | cut -d= -f2)"`
        now_timestamp=`date +%s`
        diff=$(((now_timestamp-start_timestamp) / 86400))
        if [ "$diff" -lt "2" ]; then
                echo "No renewal needed"
                exit 0
        fi
fi

cd "$WORKDIR"
# cert renewal is needed if we reached this line
echo "Renewal needed"

# cleanup
needs_cleanup=false
for f in "$WORKDIR/*.key"; do
	echo $f
    ## Check if the glob gets expanded to existing files.
    ## If not, f here will be exactly the pattern above
    ## and the exists test will evaluate to false.
	if [ -e $f ]; then
		needs_cleanup=true
	fi

    ## This is all we needed to know, so we can break after the first iteration
    break
done

if [ "$needs_cleanup" = true ]; then
	#backup
	echo "BACKUP"
	mkdir -p "$WORKDIR"/backup
	rm -f "$WORKDIR"/backup/*
	mv "$WORKDIR"/*.key "$WORKDIR"/backup/
	mv "$WORKDIR"/*.pem "$WORKDIR"/backup/

	#cleanup
	rm -f "$WORKDIR"/*.csr
	rm -f "$WORKDIR"/*.key
	rm -f "$WORKDIR"/*.pem
fi

# generate CSR
openssl req -new -config "$WORKDIR/ipa-httpd.cnf" -keyout "$WORKDIR/req.key" -out "$WORKDIR/req.csr"

# httpd process prevents letsencrypt from working, stop it
service httpd stop

# get a new cert
letsencrypt certonly --standalone --csr "$WORKDIR/req.csr" --email "$EMAIL" --agree-tos --cert-path "$WORKDIR/cert.pem" --chain-path "$WORKDIR/chain.pem" --fullchain-path "$WORKDIR/fullchain.pem"

# replace the cert
yes $DIRPASSWD "" | ipa-server-certinstall -w -d "$WORKDIR/req.key" "$WORKDIR/cert.pem"
ipactl restart