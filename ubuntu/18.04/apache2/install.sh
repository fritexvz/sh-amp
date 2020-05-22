#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/apache2/install.sh
# ./ubuntu/18.04/apache2/install.sh

# Work even if somebody does "sh thisscript.sh".
set -e

# Set global constants.
ENVPATH=""
ABSPATH=""
DIRNAME=""
OS_PATH=""
PKGNAME=""

# Set the arguments of the file.
for arg in "${@}"; do
  case "${arg}" in
  --ENVPATH=*)
    ENVPATH="$(echo "${arg}" | sed -E 's/(--ENVPATH=)//')"
    ;;
  --ABSPATH=*)
    ABSPATH="$(echo "${arg}" | sed -E 's/(--ABSPATH=)//')"
    DIRNAME="$(dirname "${ABSPATH}")"
    OS_PATH="$(dirname "${DIRNAME}")"
    PKGNAME="$(basename "${DIRNAME,,}")"
    ;;
  esac
done

# Include the file.
source "${OS_PATH}/utils.sh"
source "${OS_PATH}/functions.sh"
source "${DIRNAME}/functions.sh"

echo
echo "Start installing ${PKGNAME}."

apt -y install apache2 ssl-cert certbot

# Activates the specified module within the apache2 configuration.
a2enmod rewrite
a2enmod headers
a2enmod ssl
a2dismod -f autoindex

# mpm-itk allows you to run each of your vhost under a separate uid and gid—in short,
# the scripts and configuration files for one vhost no longer have to be readable for all the other vhosts.
apt-cache search mpm-itk
apt -y install libapache2-mpm-itk
chmod 711 /home
chmod -R 700 /home/*

# Reload the service.
systemctl reload apache2

# Create a basic SSL configuration file.
if [ -f /etc/apache2/sites-available/default-ssl.conf ]; then
  cp -v /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-available/000-default-ssl.conf
fi

# Create a backup file.
cp -v /etc/apache2/conf-available/charset.conf{,.bak}
cp -v /etc/apache2/conf-available/security.conf{,.bak}
cp -v /etc/apache2/apache2.conf{,.bak}
cp -v /etc/apache2/mods-available/mpm_prefork.conf{,.bak}
cp -v /etc/apache2/sites-available/000-default.conf{,.bak}
cp -v /etc/apache2/sites-available/000-default-ssl.conf{,.bak}

# Add a variable to the env file.
addPkgCnf -rs="\[APACHE2\]" -fs="=" -o="<<HERE
APACHE2_VERSION = $(getApache2Ver)
<<HERE"

echo
echo "${PKGNAME^} is completely installed."
