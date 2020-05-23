#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/virtualhost/uninstall.sh
# ./ubuntu/18.04/virtualhost/uninstall.sh

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
pkgAudit "apache2"

echo
echo "The ${VHOST_NAME} starts to be removed."

# Set regex pattern.
SPACE0='[\t ]{0,}'
SPACE1='[\t ]{1,}'

echo
VHOST_NAME=""
while [ -z "${VHOST_NAME}" ]; do
  VHOST_NAME="$(msg -yn -c "Enter the domain name. (ex) example.com : ")"
  if [ ! -d "/var/www/${VHOST_NAME}" ]; then
    echo "${VHOST_NAME} does not exists."
    VHOST_NAME=""
  fi
done

# Disabling virtualhost
if [ ! -z "$(a2query -s | awk '{print $1}' | egrep "^${VHOST_NAME}$")" ]; then
  cd /etc/apache2/sites-available
  a2dissite "${VHOST_NAME}.conf"
fi

# Disabling SSL virtualhost
if [ ! -z "$(a2query -s | awk '{print $1}' | egrep "^${VHOST_NAME}-ssl$")" ]; then
  cd /etc/apache2/sites-available
  a2dissite "${VHOST_NAME}-ssl.conf"
fi

# Import variables from the env file.
PUBLIC_IP="$(getPkgCnf -rs="\[HOSTS\]" -fs="=" -s="PUBLIC_IP")"

# Removing public ip address to the /etc/hosts file
if [ ! -z "$(cat "/etc/hosts" | egrep "^${PUBLIC_IP}${SPACE1}${VHOST_NAME}$")" ]; then
  sed -i -E "/^${PUBLIC_IP}${SPACE1}${VHOST_NAME}$/d" /etc/hosts
fi

# Removing virtualhost directory
if [ -d "/var/www/${VHOST_NAME}" ]; then
  rm -rf "/var/www/${VHOST_NAME}"
fi

# Reloading apache2
systemctl reload apache2

echo
echo "The ${VHOST_NAME} has been completely removed."