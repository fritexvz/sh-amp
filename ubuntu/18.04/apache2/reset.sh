#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/apache2/reset.sh
# ./ubuntu/18.04/apache2/reset.sh

# Work even if somebody does "sh thisscript.sh".
set -e

# Set constants in the file.
ENVPATH=""
ABSPATH=""
OS_PATH=""

# Set the arguments of the file.
for arg in "${@}"; do
  case "${arg}" in
  --ENVPATH=*)
    ENVPATH="$(echo "${arg}" | sed -E 's/(--ENVPATH=)//')"
    ;;
  --ABSPATH=*)
    ABSPATH="$(echo "${arg}" | sed -E 's/(--ABSPATH=)//')"
    OS_PATH="$(dirname "$(dirname "${ABSPATH}")")"
    ;;
  esac
done

# Include the file.
source "${OS_PATH}/utils.sh"
source "${OS_PATH}/functions.sh"
source "./functions.sh"

# Make sure the package is installed.
pkgAudit "apache2"

echo
echo "Reset the apache2 configuration."

# Reset the file.
cp -v /etc/apache2/conf-available/charset.conf.bak /etc/apache2/conf-available/charset.conf
cp -v /etc/apache2/conf-available/security.conf.bak /etc/apache2/conf-available/security.conf
cp -v /etc/apache2/apache2.conf.bak /etc/apache2/apache2.conf
cp -v /etc/apache2/mods-available/mpm_prefork.conf.bak /etc/apache2/mods-available/mpm_prefork.conf
cp -v /etc/apache2/sites-available/000-default.conf.bak /etc/apache2/sites-available/000-default.conf
cp -v /etc/apache2/sites-available/000-default-ssl.conf.bak /etc/apache2/sites-available/000-default-ssl.conf

# Reload the server.
systemctl reload apache2

echo
echo "The apache2 configuration has been reset."