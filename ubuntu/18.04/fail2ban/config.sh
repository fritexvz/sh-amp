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

# Set constants in the file.
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
PUBLIC_IP="$(getPkgCnf -rs="\[HOSTS\]" -fs="=" -s="PUBLIC_IP")"

echo
echo "Start setting up ${PKGNAME} configuration."

f_jail="/etc/fail2ban/jail.local"

if [ -f ".${f_jail}" ]; then
  cp -v ".${f_jail}" "${f_jail}"
else

  cat >"${f_jail}" <<FAIL2BANSCRIPT
$(cat "${DIRNAME}/tmpl/jail.local")
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
