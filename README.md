These two scripts try to automatically obtain and install Let's Encrypt certs
to FreeIPA web interface.

To use it, do this:
* BACKUP /var/lib/ipa/certs/ and /var/lib/ipa/private/ to some safe place (it contains private keys!)
* clone/unpack all scripts somewhere
* set EMAIL variable in renew-le.sh
* run setup-le.sh script once to prepare the machine. The script will:
  * install Let's Encrypt client package
  * install Let's Encrypt CA certificates into FreeIPA certificate store
  * requests new certificate for FreeIPA web interface
* run renew-le.sh script once a day: it will renew the cert as necessary

## Service files
* instead of anywhere, clone/unpack all the scripts into `/usr/local/sbin/ipa-certbot/` instead.
* copy `freeipa-certbot.service` and `freeipa-certbot.timer` into `/etc/systemd/system/`
* run `systemctl daemon-reload; systemctl enable freeipa-certbot.service; systemctl enable freeipa-certbot.timer --now`


If you have any problem, feel free to contact FreeIPA team:
http://www.freeipa.org/page/Contribute#Communication
