#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/vhost/uninstall.sh
# ./ubuntu/18.04/vhost/uninstall.sh

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
pkgAudit "apache2"

echo
VHOST_NAME=""
while [ -z "${VHOST_NAME}" ]; do
  VHOST_NAME="$(msg -yn -p1='Enter server name. (ex) example.com : ' -p2='Are you sure you want to save this? (y/n) ')"
  if [ ! -d "/var/www/${VHOST_NAME} "]; then
    echo "${VHOST_NAME} does not exists."
    VHOST_NAME=""
  fi
done

echo
if [ "$(msg -yn 'Are you sure you want to remove it? (y/n) ')" == "Yes" ]; then
  echo
  echo "The ${VHOST_NAME} starts to be removed."

  # Disabling virtualhost
  if [ ! -z "$(a2query -s | egrep "${VHOST_NAME}\s+")" ]; then
    a2dissite "${VHOST_NAME}.conf"
  fi

  # Disabling SSL virtualhost
  if [ ! -z "$(a2query -s | egrep "${VHOST_NAME}-ssl\s+")" ]; then
    a2dissite "${VHOST_NAME}-ssl.conf"
  fi

  # Import variables from the env file.
  PUBLIC_IP="$(getPkgCnf -rs="\[HOSTS\]" -fs="=" -s="PUBLIC_IP")"

  # Removing public ip address to the /etc/hosts file
  if [ ! -z "$(cat "/etc/hosts" | egrep "^${PUBLIC_IP}\s+${VHOST_NAME}$")" ]; then
    sed -i -E "/^${PUBLIC_IP}\s+${VHOST_NAME}$/d" /etc/hosts
  fi

  # Removing virtualhost directory
  if [ -d "/var/www/${VHOST_NAME}" ]; then
    rm -rf "/var/www/${VHOST_NAME}"
  fi

  # Reloading apache2
  systemctl reload apache2

  echo
  echo "The ${VHOST_NAME} has been completely removed."
fi
