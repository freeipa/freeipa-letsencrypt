These two scripts try to automatically obtain and install Let's Encrypt certs
to FreeIPA web interface.

To use it, do this:
* BACKUP /etc/httpd/alias to some safe place (it contains private keys!)
* clone/unpack all scripts including "ca" subdirectory somewhere
* set WORKDIR and EMAIL variables in scripts setup-le.sh and renew-le.sh
* run setup-le.sh script once to prepare the machine. The script will:
  * install Let's Encrypt client package
  * install Let's Encrypt CA certificates into FreeIPA certificate store
  * requests new certificate for FreeIPA web interface
* run renew-le.sh script once a day: it will renew the cert as necessary


If you have any problem, feel free to contact FreeIPA team:
http://www.freeipa.org/page/Contribute#Communication
