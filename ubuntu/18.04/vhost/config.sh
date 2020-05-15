#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/vhost/config.sh
# ./ubuntu/18.04/vhost/config.sh

# Work even if somebody does "sh thisscript.sh".
set -e

# Set constants in the file.
ENVPATH=""
ABSPATH=""
DIRNAME=""
OS_PATH=""
PKGNAME=""
VHOST_NAME=""

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
  --vhostname=*)
    VHOST_NAME="$(echo "${arg}" | sed -E 's/(--vhostname=)//')"
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
echo "Start setting up ${PKGNAME} configuration."

VHOST_DIR="/var/www/${VHOST_NAME}"
VHOST_ROOT_DIR="${VHOST_DIR}/html"
VHOST_LOG_DIR="${VHOST_DIR}/logs"

# Setting up vhosting directory
if [ ! -d "${VHOST_ROOT_DIR}" ]; then
  mkdir -p "${VHOST_ROOT_DIR}"
fi

if [ ! -d "${VHOST_LOG_DIR}" ]; then
  mkdir -p "${VHOST_LOG_DIR}"
fi

chown -R www-data:www-data "${VHOST_DIR}"
chmod -R 775 "${VHOST_DIR}"

# Creating new vhosting files
f_80="/etc/apache2/sites-available/000-default.conf"

if [ -f ".${f_80}" ]; then
  cp -v ".${f_80}" "/etc/apache2/sites-available/${VHOST_NAME}.conf"
else
  cat >"/etc/apache2/sites-available/${VHOST_NAME}.conf" <<VHOSTCONFSCRIPT
$(cat ./tmpl/vhost.conf)
VHOSTCONFSCRIPT
fi

sed -i -E \
  -e "s/VHOST_NAME/${VHOST_NAME}/g" \
  -e "s/VHOST_ROOT_DIR/${VHOST_ROOT_DIR}/g" \
  -e "s/VHOST_LOG_DIR/${VHOST_LOG_DIR}/g" \
  "/etc/apache2/sites-available/${VHOST_NAME}.conf"

# Disabling default vhosting
if [ ! -z "$(a2query -s | egrep "000-default\s+")" ]; then
  a2dissite 000-default.conf
fi

# Enabling new vhosting
a2ensite "${VHOST_NAME}.conf"

# 000-default-ssl configure
APACHE2_HTTPS="$(getPkgCnf -rs="\[APACHE2\]" -fs="=" -s="APACHE2_HTTPS")"

# Creating new SSL vhosting files
if [ "${APACHE2_HTTPS^^}" == "ON" ]; then

  f_443="/etc/apache2/sites-available/000-default-ssl.conf"

  if [ -f ".${f_443}" ]; then
    cp -v ".${f_443}" "/etc/apache2/sites-available/${VHOST_NAME}-ssl.conf"
  else
    cat >"/etc/apache2/sites-available/${VHOST_NAME}-ssl.conf" <<VHOSTCONFSCRIPT
$(cat ./tmpl/vhost-ssl.conf)
VHOSTCONFSCRIPT
  fi

  sed -i -E \
    -e "s/VHOST_NAME/${VHOST_NAME}/g" \
    -e "s/VHOST_ROOT_DIR/${VHOST_ROOT_DIR}/g" \
    -e "s/VHOST_LOG_DIR/${VHOST_LOG_DIR}/g" \
    "/etc/apache2/sites-available/${VHOST_NAME}-ssl.conf"

  # Disabling default SSL vhosting
  if [ ! -z "$(a2query -s | egrep "000-default-ssl\s+")" ]; then
    a2dissite 000-default-ssl.conf
  fi

  # Enabling new ssl vhosting
  a2ensite "${VHOST_NAME}-ssl.conf"

fi

# Import variables from the env file.
PUBLIC_IP="$(getPkgCnf -rs="\[HOSTS\]" -fs="=" -s="PUBLIC_IP")"

# Adding virtual host name to the /etc/hosts file.
if [ -z "$(cat "/etc/hosts" | egrep "^${PUBLIC_IP}\s+${VHOST_NAME}$")" ]; then
  sed -i "2 a\\${PUBLIC_IP} ${VHOST_NAME}" /etc/hosts
fi

# Reload the service
systemctl reload apache2

echo
echo "${PKGNAME^} configuration is complete."
