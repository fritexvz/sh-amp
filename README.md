# amp   
Easy and fast installation of the latest version of the amp stack (apache2 + mariadb10 + php7 + vsftpd + sendmail).   

## Firewall   
If you are installing scripts on cloud servers like aws, gcloud and azure, you need to open the following ports.   
```
apache: 80/tcp, 443/tcp
ssh: 22/tcp
ftp: 21/tcp, 990/tcp, 12000:12100/tcp
db: 3306/tcp, 5432/tcp
memcached: 11211/tcp
redis: 6379/tcp
elasticsearch: 9200/tcp
smtp: 25/tcp, 465/tcp, 587/tcp, 2525/tcp
pop3: 110/tcp, 995/tcp
imap: 143/tcp, 993/tcp
```

## Install   
```
# sudo su
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./*.sh
# ./install.sh
```

## Config   
Only configuration settings are installed.
```
# ./config.sh
```

## Update   
```
# ./update.sh
```

## Restore   
The configuration settings return to the initial settings.   
```
# ./restore.sh
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

## License   
[MIT License](LICENSE)   