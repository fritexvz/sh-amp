#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/amp-restore.sh
# ./ubuntu/18.04/amp-restore.sh

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
  if [ -f $1.bak ]; then
    cp $1.bak $1
  fi
}


#
# Main Script

#
# apache2
printf "\n\nRestoring apache2's configuration settings ... \n"
copy "/etc/apache2/conf-available/charset.conf"
copy "/etc/apache2/conf-available/security.conf"
copy "/etc/apache2/apache2.conf"
copy "/etc/apache2/mods-available/mpm_prefork.conf"
copy "/etc/apache2/sites-available/000-default.conf"
copy "/etc/apache2/sites-available/000-default-ssl.conf"

#
# sendmail
printf "\n\nRestoring sendmail's configuration settings... \n"
copy "/etc/mail/local-host-names"

#
# fail2ban
printf "\n\nRestoring fail2ban's configuration settings... \n"
copy "/etc/fail2ban/jail.local"

#
# mariadb
printf "\n\nRestoring mariadb's configuration settings ... \n"
copy "/etc/mysql/mariadb.conf.d/50-server.cnf"
copy "/etc/my.cnf"

#
# php
# Detect php version
PHP_VEROUT=$(php -v)
PHP_VERSION=$(expr substr "$PHP_VEROUT" 5 3)

printf "\n\nRestoring php's configuration settings ... \n"
copy "/etc/apache2/mods-available/dir.conf"
copy "/etc/apache2/mods-available/php$PHP_VERSION.conf"
copy "/etc/php/$PHP_VERSION/apache2/php.ini"

#
# vsftpd
printf "\n\nRestoring vsftpd's configuration settings ... \n"
copy "/etc/vsftpd.conf"
copy "/etc/vsftpd.user_list"
copy "/etc/vsftpd.chroot_list"

#
# ufw
printf "\n\nRestoring ufw's configuration settings ... \n"
ufw --force disable
ufw --force reset