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

# Set a relative path.
FILENAME="$(basename $0)"
PKGPATH="$(dirname $0)"
PKGNAME="$(basename "${PKGPATH}")"
OSPATH="$(dirname "${PKGPATH}")"
LIBPATH="${PKGPATH}/lib"
TMPLPATH="${PKGPATH}/tmpl"

# Set absolute path.
ABSROOT="$(cd "$(dirname "")" && pwd)"
ABSENV="${ABSROOT}/env"
ABSOS="${ABSROOT}/${OSPATH}"
ABSPKG="${ABSOS}/${PKGNAME}"
ABSLIB="${ABSPKG}/lib"
ABSTMPL="${ABSPKG}/tmpl"
ABSPATH="${ABSPKG}/${FILENAME}"

# Include the file.
source "${ABSOS}/constants.sh"
source "${ABSOS}/utils.sh"
source "${ABSOS}/functions.sh"
source "${ABSPKG}/functions.sh"

echo
echo "Start installing ${PKGNAME}."

# Make sure the package is installed.
if [ ! -z "$(is${PKGNAME^})" ]; then
  CONFIRM_MESSAGE="$(msg -yn "The ${PKGNAME} package is already installed. Would you like to reinstall? (y/n) ")"
  if [ CONFIRM_MESSAGE == "No" ]; then
    exit 0
  fi
fi

apt -y install apache2 ssl-cert certbot

# Start the package and set it to start on boot.
pkgOnBoot "apache2"

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

# Create backup and configuration files.
addPkgCnf "/etc/apache2/conf-available/charset.conf"
addPkgCnf "/etc/apache2/conf-available/security.conf"
addPkgCnf "/etc/apache2/apache2.conf"
addPkgCnf "/etc/apache2/mods-available/mpm_prefork.conf"
addPkgCnf "/etc/apache2/sites-available/000-default.conf"
addPkgCnf "/etc/apache2/sites-available/000-default-ssl.conf"

# Add a variable to the env file.
setPkgCnf -rs="\[APACHE2\]" -fs="=" -o="<<HERE
APACHE2_VERSION = $(getApache2Ver)
<<HERE"

echo
echo "${PKGNAME^} is completely installed."
