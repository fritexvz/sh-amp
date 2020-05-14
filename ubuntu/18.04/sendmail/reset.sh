#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/sendmail/reset.sh
# ./ubuntu/18.04/sendmail/reset.sh

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
pkgAudit "sendmail"

echo
echo "Reset the sendmail configuration."

# Reset the file.
cp -v /etc/mail/local-host-names.bak /etc/mail/local-host-names

# Restart the service.
systemctl restart sendmail
if [ ! -z "$(isApache2)" ]; then
  systemctl restart apache2
fi

echo
echo "The sendmail configuration has been reset."