These two scripts try to automatically obtain and install Let's Encrypt certs
to FreeIPA web interface.

To use it, do this:
* BACKUP /etc/httpd/alias to some safe place (it contains private keys!)
* clone/unpack all scripts including "ca" subdirectory somewhere (/root/ipa-le is the default)
* set WORKDIR variable to the directory you cloned the repository to in scripts setup-le.sh and renew-le.sh
* set EMAIL variable in script renew-le.sh
* run "yum install dnf" (a stock FreeIPA machine doesn't have dnf installed)
* run "kinit your-admin-username" to get a Kerberos ticket (necessary to install the new certificates)
* run setup-le.sh script once to prepare the machine. The script will:
  * install Let's Encrypt client package
  * install Let's Encrypt CA certificates into FreeIPA certificate store
  * requests new certificate for FreeIPA web interface
* run renew-le.sh script once a day: it will renew the cert as necessary
  * run "crontab -e" as root
  * add the line "* * * * * /root/ipa-le/renew-le.sh"


If you have any problem, feel free to contact FreeIPA team:
http://www.freeipa.org/page/Contribute#Communication
