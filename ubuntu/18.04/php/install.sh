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

# Set constants in the file.
ENVPATH=""
ABSPATH=""
DIRNAME=""
OS_PATH=""

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
    ;;
  esac
done

# Include the file.
source "${OS_PATH}/utils.sh"
source "${OS_PATH}/functions.sh"
source "${DIRNAME}/functions.sh"

echo
echo "Start installing PHP."

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

# Restart the service.
if [ ! -z "$(isApache2)" ]; then
  systemctl restart apache2
fi

# Import variables from the env file.
PHP_VERSION="$(getPhpVer)"

# Create a backup file.
cp -v "/etc/apache2/mods-available/dir.conf"{,.bak}
cp -v "/etc/apache2/mods-available/php${PHP_VERSION}.conf"{,.bak}
cp -v "/etc/php/${PHP_VERSION}/apache2/php.ini"{,.bak}

# Add a variable to the env file.
addPkgCnf -rs="\[PHP\]" -fs="=" -o="<<HERE
PHP_VERSION = ${PHP_VERSION}
<<HERE"

echo
echo "PHP is completely installed."
