#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/fail2ban/install.sh
# ./ubuntu/18.04/fail2ban/install.sh

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

echo
echo "Start installing ${PKGNAME}."

apt -y install fail2ban whois

# Create a blank file.
if [ ! -f /etc/fail2ban/jail.local ]; then
  echo "" >/etc/fail2ban/jail.local
fi

# Create a backup file.
cp -v /etc/fail2ban/jail.conf{,.bak}
cp -v /etc/fail2ban/jail.local{,.bak}

# Add a variable to the env file.
addPkgCnf -rs="\[FAIL2BAN\]" -fs="=" -o="<<HERE
FAIL2BAN_VERSION = $(getFail2banVer)
<<HERE"

echo
echo "${PKGNAME^} is completely installed."
