# Amp Stack   
Easy and fast installation of the latest version of the amp stack (apache2 + ufw + fail2ban + vsftpd + sendmail + mariadb10 + php7 + npm + laravel + wp-cli + virtualhost) on ubuntu 18.04+.   

## Firewall   
If you are installing scripts on cloud servers like aws, gcloud and azure, you need to open the following ports.   
```
apache: 80/tcp, 443/tcp
ssh: 22/tcp
ftp: 20:21/tcp, 990/tcp, 12000:12100/tcp
mariadb: 3306/tcp
memcached: 11211/tcp
redis: 6379/tcp
elasticsearch: 9200/tcp
smtp: 25/tcp, 465/tcp, 587/tcp, 2525/tcp
pop3: 110/tcp, 995/tcp
imap: 143/tcp, 993/tcp
```

## Install   
```
$ sudo su
$ git clone https://github.com/w3src/sh-amp.git
$ cd sh-amp
$ chmod +x ./*.sh
$ ./install.sh
```

## Virtualhost   
```
$ ./virtualhost.sh
```

## Config   
Configuration settings are installed.   
```
$ ./config.sh
```

## Update   
Download the latest version of the amp stack.
```
$ ./update.sh
```

## Upgrade   
Run the package's apt upgrade.
```
$ ./upgrade.sh
```

## Reset   
The configuration settings return to the initial settings.   
```
$ ./reset.sh
```

## Uninstall   
You can remove it by selecting the package.   
```
$ ./uninstall.sh
```

## Wizard   
Frequently used systemctl commands such as status, start, stop, reload, restart, enable, disable and etc.
```
$ ./wizard.sh
```

## List of installed php modules for wordpress and laravel   
```
php-common
libapache2-mod-php
php-mysql
php-curl
php-json
php-mbstring
php-imagick
php-xml
php-zip
php-gd
php-ssh2
php-bcmath
php-json
php-xml
php-mbstring
php-tokenizer
php-oauth
composer
```

## Support
ubuntu 18.04+

## License   
[MIT License](LICENSE)   