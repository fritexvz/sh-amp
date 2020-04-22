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

# Work even if somebody does "sh thisscript.sh".
set -e

# Check to see if script is being run as root
if [ "$(whoami)" != 'root' ]; then
  echo "You have no permission to run $0 as non-root user. Use sudo"
  exit
fi

# Check if git is installed
if ! hash git 2>/dev/null; then
  echo -e "Git is not installed! You will need it at some point anyways..."
  echo -e "Exiting, install git first."
  exit 0
fi

#
# Functions
function copy() {
  if [ -f $1 ]; then
    cp $1{,.bak}
  fi
}

function username_exists() {
  if ! cut -d: -f1 /etc/passwd | egrep -q "^$1$"; then
    echo "The user '$1' does not exist."
    exists_username=""
    while [[ -z "$exists_username" ]]; do
      read -p "username: " exists_username
      if ! cut -d: -f1 /etc/passwd | egrep -q "^$exists_username$"; then
        echo "The user '$exists_username' does not exist."
        exists_username=""
      fi
    done
  else
    exists_username="$1"
  fi
}

function username_create() {
  if cut -d: -f1 /etc/passwd | egrep -q "^$1$"; then
    echo "The user '$1' already exists."
    create_username=""
    while [[ -z "$create_username" ]]; do
      read -p "username: " create_username
      if cut -d: -f1 /etc/passwd | egrep -q "^$create_username$"; then
        echo "The user '$create_username' already exists."
        create_username=""
      fi
    done
  else
    create_username="$1"
  fi
}

#
# Main Script

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
# sendmail
printf "\n\nInstalling sendmail ... \n"
apt -y install sendmail

printf "\n\nCreate a file to restore configuration settings of sendmail ... \n"
copy "/etc/mail/local-host-names"

printf "\n\nRestarting sendmail ... \n"
systemctl restart sendmail
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
# fail2ban
printf "\n\nInstalling fail2ben ... \n"
apt -y install fail2ban whois

printf "\n\nCreate a file to restore configuration settings of fail2ban ... \n"
copy "/etc/fail2ban/jail.conf"
if [ ! -f /etc/fail2ban/jail.local ]; then
  echo "" >/etc/fail2ban/jail.local
fi

printf "\n\nRestarting fail2ban ... \n"
systemctl restart fail2ban

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
echo
while true; do
  read -p "Create a new ftp user? (y/n) " answer
  case $answer in
  y | Y)
    answer_user_create="YES"
    break
    ;;
  n | N)
    answer_user_create="NO"
    break
    ;;
  esac
done

if [ $answer_user_create == "YES" ]; then
  username=""
  while [[ -z "$username" ]]; do
    read -p "username: " username
  done
fi

if [ $answer_user_create == "YES" ]; then
  username_create "$username"
  adduser $create_username
  if ! egrep -q "^$create_username$" /etc/vsftpd.user_list; then
    echo "$create_username" | tee -a /etc/vsftpd.user_list
  else
    echo $create_username " is already in user_list."
  fi
  echo "New users have been added."
fi

if [ $answer_user_create == "YES" ]; then
  echo
  while true; do
    read -p "Do you want to allow user's root access? (y/n) " answer
    case $answer in
    y | Y)
      answer_root_access="YES"
      break
      ;;
    n | N)
      answer_root_access="NO"
      break
      ;;
    esac
  done
fi

if [ $answer_user_create == "YES" ] && [ $answer_root_access == "YES" ]; then
  username_exists "$username"
  if ! egrep -q "^$exists_username$" /etc/vsftpd.chroot_list; then
    echo "$exists_username" | tee -a /etc/vsftpd.chroot_list
    echo "Root access of $exists_username is allowed."
  else
    echo $exists_username " is already in chroot_list."
  fi
fi

printf "\n\nRestarting vsftpd ... \n"
systemctl restart vsftpd
