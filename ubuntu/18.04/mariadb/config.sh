#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/mariadb/config.sh
# ./ubuntu/18.04/mariadb/config.sh

# Work even if somebody does "sh thisscript.sh".
set -e

# Set constants.
OSPATH="$(dirname "$(dirname $0)")"
PKGNAME="$(basename "$(dirname $0)")"
FILENAME="$(basename $0)"

# Set directory path.
ABSROOT="${1#*=}"
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
echo "Start setting up ${PKGNAME} configuration."

f1="/etc/my.cnf"
if [ -f ".${f1}" ]; then
  cp -v ".${f1}" "${f1}"
else
  cat >"${f1}" <<MYCNFSCRIPT
$(cat "${ABSPKG}/tmpl/my.cnf")
MYCNFSCRIPT
fi

# Restart the package.
systemctl restart mariadb

echo
echo "${PKGNAME^} configuration is complete."
