# amp stack   
Easy and fast installation of the latest version of the amp stack (apache2 + mariadb10 + php7 + fail2ban + vsftpd + sendmail + virtualhost).   

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
# sudo su
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./*.sh
# ./install.sh
```

## Config   
Configuration settings are installed.   
```
# ./config.sh
```

## User   
You can change the default options for ftp users.   
- Create a new ftp user?   
- Allow user's root access?   
- Change user's password?   
- Change user's home directory?   
- Delete a exist user?   
- Allow access to the root account?   
```
# ./user.sh
```

## Virtualhost   
```
# ./vhost.sh
```

## Fail2ban   
You can choose from the questions below.   
- Restart fail2ban?   
- Check the status?   
- Unban the IP?   
- Check the log?   
```
# ./fail2ban.sh
```

## Restart   
- apache2   
- ufw   
- fail2ban   
- vsftpd    
- mariadb   
```
# ./restart.sh
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