#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/sendmail/config.sh
# ./ubuntu/18.04/sendmail/config.sh

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

echo
echo "Start setting up ${PKGNAME} configuration."

f_mail="/etc/mail/local-host-names"

if [ -f ".${f_mail}" ]; then
  cp -v ".${f_mail}" "${f_mail}"
else
  echo "localhost" >"${f_mail}"
fi

# Restart the service.
systemctl restart sendmail
if [ ! -z "$(isApache2)" ]; then
  systemctl restart apache2
fi

echo
echo "${PKGNAME^} configuration is complete."
