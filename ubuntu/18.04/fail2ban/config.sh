#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/fail2ban/config.sh
# ./ubuntu/18.04/fail2ban/config.sh

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
echo "Start setting up ${PKGNAME} configuration."

# Import variables from the env file.
PUBLIC_IP="$(getPkgCnf -rs="\[HOSTS\]" -fs="=" -s="PUBLIC_IP")"

f_jail="/etc/fail2ban/jail.local"

if [ -f ".${f_jail}" ]; then
  cp -v ".${f_jail}" "${f_jail}"
else

  cat >"${f_jail}" <<FAIL2BANSCRIPT
$(cat "${ABSPKG}/tmpl/jail.local")
FAIL2BANSCRIPT

  # Public IP are added to the whitelist
  addPkgCnf -f="${f_jail}" -rs="\[DEFAULT\]" -fs="=" -o="<<HERE
ignoreip = 127.0.0.1/8 127.0.1.1 ${PUBLIC_IP}
<<HERE"

fi

# Restart the package.
service fail2ban restart

echo
echo "${PKGNAME^} configuration is complete."
