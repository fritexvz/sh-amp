#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/amp.sh
# ./ubuntu/18.04/amp.sh

# Check to see if script is being run as root
if [ "$(whoami)" != 'root' ]; then
  echo "You have no permission to run $0 as non-root user. Use sudo"
  exit
fi

set -e # Work even if somebody does "sh thisscript.sh".

function copy() {
  if [ -f $1 ]; then
    cp $1{,.bak}
  fi
}

#
# os
printf "\n\nUpdating and Upgrading System ... \n"
apt update && apt -y upgrade

printf "\n\nInstalling prerequisites ... \n"
apt -y install git curl wget zip unzip vim

printf "\n\nRemoving unused dependencies ... \n"
apt -y autoremove

printf "\n\nSetting up Timezone ... \n"
dpkg-reconfigure tzdata

#
# hostname
printf "\n\nUpdate hostname... \n"
HOSTNAME=""
while [[ -z "$HOSTNAME" ]]; do
  read -p "hostname or FQDN (ex) www.example.com : " HOSTNAME
done

if [ hostname != "$HOSTNAME" ]; then
  hostnamectl set-hostname "$HOSTNAME"
fi

printf "\n\nCreate a file to restore configuration settings of hostname ... \n"
copy "/etc/hosts"
copy "/etc/cloud/cloud.cfg"

if [ -f /etc/hosts ]; then
  printf "\n\nSetting up hosts ... \n"
  if ! grep -q "127.0.1.1 $HOSTNAME" /etc/hosts; then
    sed -i "1 a\127.0.1.1 $HOSTNAME" /etc/hosts
  fi
fi

# This will cause the set+update hostname module to not operate (if true)
if [ -f /etc/cloud/cloud.cfg ]; then
  printf "\n\nSetting up cloud.cfg ... \n"
  sed -i -E -e '/preserve_hostname\s{0,}?\:/{ s/\:.*/\: true/; }' /etc/cloud/cloud.cfg
fi

#
# apache2
printf "\n\nInstalling apache2 ... \n"
apt -y install apache2 ssl-cert certbot

printf "\n\nEnabling apache2 modules ... \n"
a2enmod rewrite
a2enmod headers
a2enmod ssl
a2dismod -f autoindex

if [ -f /etc/apache2/sites-available/default-ssl.conf ]; then
  cp /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-available/000-default-ssl.conf
fi

printf "\n\nCreate a file to restore configuration settings of apache2 ... \n"
copy "/etc/apache2/conf-available/charset.conf"
copy "/etc/apache2/conf-available/security.conf"
copy "/etc/apache2/apache2.conf"
copy "/etc/apache2/mods-available/mpm_prefork.conf"
copy "/etc/apache2/sites-available/000-default.conf"
copy "/etc/apache2/sites-available/000-default-ssl.conf"

printf "\n\nRestarting apache2 ... \n"
systemctl restart apache2

#
# firewall
printf "\n\nOpening port ... \n"

# Allow access to Apache on both port 80 and 443:
ufw allow in "Apache Full"

# open ssh port 22
ufw allow OpenSSH

# open ftp: data and command port
ufw allow 20:21/tcp

# open ftp: require implicit FTP over TLS port
ufw allow 990/tcp

# open ftp: passive ports range port
ufw allow 12000:12100/tcp

# open db: mysql
ufw allow 3306/tcp
ufw allow 5432/tcp

# open php: memcached
ufw allow 11211/tcp

# open php: redis
ufw allow 6379/tcp

# open php: elasticsearch
ufw allow 9200/tcp

# open mail: smtp
ufw allow 25/tcp
ufw allow 465/tcp
ufw allow 587/tcp
ufw allow 2525/tcp

# open mail: pop3
ufw allow 110/tcp
ufw allow 995/tcp

# open mail: imap
ufw allow 143/tcp
ufw allow 993/tcp

printf "\n\nEnabling port ... \n"
ufw disable
ufw enable

#
# mariadb
printf "\n\nInstalling mariadb ... \n"
apt -y install mariadb-server mariadb-client

printf "\n\nSetting up mysql_secure_installation ... \n"
/usr/bin/mysql_secure_installation

if [ ! -f /etc/my.cnf ]; then
  echo "" >/etc/my.cnf
fi

printf "\n\nCreate a file to restore configuration settings of mariadb ... \n"
copy "/etc/mysql/mariadb.conf.d/50-server.cnf"
copy "/etc/my.cnf"

printf "\n\nRestarting mariadb ... \n"
service mysqld restart

#
# php
printf "\n\nInstalling php modules ... \n"

# Installing php extensions for lamp
apt -y install php php-common libapache2-mod-php php-mysql

# Required php extensions for wordpress
# https://make.wordpress.org/hosting/handbook/handbook/server-environment/#php-extensions
apt -y install php-curl php-json php-mbstring php-imagick php-xml php-zip php-gd php-ssh2

# Required php extensions for laravel
# https://laravel.com/docs/7.x#server-requirements
apt -y install php-bcmath php-json php-xml php-mbstring php-tokenizer composer

# Required php extensions for cloud API
apt -y install php-oauth

# Search php modules
#apt-cache search php- | grep ^php- | grep module

# Detect php version
PHP_VEROUT=$(php -v)
PHP_VERSION=$(expr substr "$PHP_VEROUT" 5 3)

printf "\n\nCreate a file to restore configuration settings of php ... \n"
copy "/etc/apache2/mods-available/dir.conf"
copy "/etc/apache2/mods-available/php$PHP_VERSION.conf"
copy "/etc/php/$PHP_VERSION/apache2/php.ini"

printf "\n\nRestarting apache2 ... \n"
systemctl restart apache2

#
# sendmail
printf "\n\nInstalling sendmail ... \n"
apt -y install sendmail

printf "\n\nCreate a file to restore configuration settings of sendmail ... \n"
copy "/etc/mail/local-host-names"

printf "\n\nRestarting apache2 ... \n"
systemctl restart apache2

#
# vsftpd
printf "\n\nInstalling vsftpd ... \n"
apt -y install vsftpd

printf "\n\nCreate a file to restore configuration settings of vsftpd ... \n"
copy "/etc/vsftpd.conf"
copy "/etc/ftpusers"
copy "/etc/vsftpd.user_list"
copy "/etc/vsftpd.chroot_list"

# Restart vsftpd. And when Ubuntu restarts, it runs like this:
printf "\n\nRestarting vsftpd ... \n"
systemctl stop vsftpd.service
systemctl start vsftpd.service
systemctl enable vsftpd.service

printf "\n\nCreate a new ftp user ... \n"
while true; do
  echo
  echo
  read -p "Create a new ftp user? (y/n)? " answer
  case $answer in
  y | Y)
    while [[ -z "$FTP_USERNAME" ]]; do
      read -p "username: " FTP_USERNAME
      if cut -d: -f1 /etc/passwd | grep -q "$FTP_USERNAME"; then
        echo "The user '$FTP_USERNAME' already exists."
        FTP_USERNAME=""
      fi
    done
    break
    ;;
  n | N)
    break
    ;;
  esac
done

if [ ! -z $FTP_USERNAME ]; then
  adduser $FTP_USERNAME
  if ! grep -q "$FTP_USERNAME" /etc/vsftpd.user_list; then
    echo "$FTP_USERNAME" | tee -a /etc/vsftpd.user_list
  fi
fi

if [ ! -z $FTP_USERNAME ]; then
  while true; do
    echo
    read -p "Do you want to allow user's root access? (y/n)? " answer
    case $answer in
    y | Y)
      if ! grep -q "$FTP_USERNAME" /etc/vsftpd.chroot_list; then
        echo "$FTP_USERNAME" | tee -a /etc/vsftpd.chroot_list
      fi
      break
      ;;
    n | N)
      break
      ;;
    esac
  done
fi

systemctl restart vsftpd
