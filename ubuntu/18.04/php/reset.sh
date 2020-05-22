#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/php/reset.sh
# ./ubuntu/18.04/php/reset.sh

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

# Make sure the package is installed.
pkgAudit "${PKGNAME}"

# Import variables from the env file.
PHP_VERSION="$(getPkgCnf -rs="\[PHP\]" -fs="=" -s="PHP_VERSION")"

echo
echo "Reset the ${PKGNAME} configuration."

# Reset the file.
cp -v "/etc/apache2/mods-available/dir.conf.bak" "/etc/apache2/mods-available/dir.conf"
cp -v "/etc/apache2/mods-available/php${PHP_VERSION}.conf.bak" "/etc/apache2/mods-available/php${PHP_VERSION}.conf"
cp -v "/etc/php/${PHP_VERSION}/apache2/php.ini.bak" "/etc/php/${PHP_VERSION}/apache2/php.ini"

# Reload the service.
if [ ! -z "$(isApache2)" ]; then
  systemctl reload apache2
fi

echo
echo "The ${PKGNAME} configuration has been reset."