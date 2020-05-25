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

# Set constants.
OSPATH="$(dirname "$(dirname $0)")"
PKGPATH="$(dirname $0)"
PKGNAME="$(basename "$(dirname $0)")"
FILENAME="$(basename $0)"

# Set directory path.
ABSROOT="$(cd "$(dirname "")" && pwd)"
ABSENV="${ABSROOT}/env"
ABSOS="${ABSROOT}/${OSPATH}"
ABSPKG="${ABSOS}/${PKGNAME}"
ABSPATH="${ABSPKG}/${FILENAME}"

# Include the file.
source "${ABSOS}/utils.sh"
source "${ABSOS}/functions.sh"
source "${ABSPKG}/functions.sh"

# Make sure the package is installed.
pkgAudit "${PKGNAME}"

echo
echo "Reset the ${PKGNAME} configuration."

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
echo "The ${PKGNAME} configuration has been reset."