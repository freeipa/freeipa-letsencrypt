These two scripts try to automatically obtain and install Let's Encrypt certs
to FreeIPA web interface.

To use it, do this:
* BACKUP /var/lib/ipa/certs/ and /var/lib/ipa/private/ to some safe place (it contains private keys!)
* clone/unpack all scripts somewhere (e.g. /opt/) where they are going to run and create directories and files
* set DIRPASSWD and EMAIL variable in renew-le.sh
* set FQDN in ipa-httpd.cnf
* retrieve current ticket for admin (kinit admin)
* run setup-le.sh script once to prepare the machine. The script will:
  * install Let's Encrypt client package
  * install Let's Encrypt CA certificates into FreeIPA certificate store
  * requests new certificate for FreeIPA web interface
* run renew-le.sh script as needed (e.g. daily, weekly)

If you have any problem, feel free to contact FreeIPA team:
http://www.freeipa.org/page/Contribute#Communication