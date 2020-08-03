#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/php/install.sh
# ./ubuntu/18.04/php/install.sh

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

echo
echo "Start installing ${PKGNAME^^}."

# Make sure the package is installed.
if [ ! -z "$(is${PKGNAME^})" ]; then
  CONFIRM_MESSAGE="$(msg -yn "The ${PKGNAME} package is already installed. Would you like to reinstall? (y/n) ")"
  if [ CONFIRM_MESSAGE == "No" ]; then
    exit 0
  fi
fi

# Installing php extensions for amp.
apt -y install php php-common libapache2-mod-php php-mysql

# Required php extensions for wordpress.
# https://make.wordpress.org/hosting/handbook/handbook/server-environment/#php-extensions
apt -y install php-curl php-json php-mbstring php-imagick php-xml php-zip php-gd php-ssh2

# Required php extensions for laravel.
# https://laravel.com/docs/7.x#server-requirements
apt -y install php-bcmath php-json php-xml php-mbstring php-tokenizer composer

# Required php extensions for cloud API.
apt -y install php-oauth

# Search php modules.
#apt-cache search php- | grep ^php- | grep module

# Reloading the service.
systemctl reload apache2

# Import variables from the env file.
PHP_VERSION="$(getPhpVer)"

# Create backup and configuration files.
addPkgCnf "/etc/apache2/mods-available/dir.conf"
addPkgCnf "/etc/apache2/mods-available/php${PHP_VERSION}.conf"
addPkgCnf "/etc/php/${PHP_VERSION}/apache2/php.ini"

# Add a variable to the env file.
setPkgCnf -rs="\[PHP\]" -fs="=" -o="<<HERE
PHP_VERSION = ${PHP_VERSION}
<<HERE"

echo
echo "${PKGNAME^^} is completely installed."
