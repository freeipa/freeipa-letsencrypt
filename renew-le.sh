#!/usr/bin/bash
set -o nounset -o errexit

### cron
# check that the cert will last at least 2 days from now
# TODO: uncomment after the first run
#certutil -d /etc/httpd/alias/ -V -u V -n Server-Cert -b "$(date '+%y%m%d%H%M%S%z' --date='2 days')" && exit 0

# cert renewal is needed if we reached this line

# cleanup
rm -f /root/*.pem
rm -f /root/httpd-csr.*

# generate CSR
certutil -R -d /etc/httpd/alias/ -k Server-Cert -f /etc/httpd/alias/pwdfile.txt -s "CN=$(hostname)" --extSAN "dns:$(hostname)" -a -o /root/httpd-csr.pem
openssl req -in /root/httpd-csr.pem -outform der -out /root/httpd-csr.der

# httpd process prevents letsencrypt from working, stop it
service httpd stop

# get a new cert
letsencrypt certonly --standalone --csr /root/httpd-csr.der --email letsencrypt@example.com --agree-tos

# remove old cert
certutil -D -d /etc/httpd/alias/ -n Server-Cert
# add the new cert
certutil -A -d /etc/httpd/alias/ -n Server-Cert -t ,, -a -i /root/0000_cert.pem

# start httpd with the new cert
service httpd start
