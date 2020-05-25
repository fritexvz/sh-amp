#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/virtualhost/config.sh
# ./ubuntu/18.04/virtualhost/config.sh

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
pkgAudit "apache2"

echo
echo "Start setting up ${PKGNAME} configuration."

# Set constants.
VHOST_NAME=""
VHOST_DIR=""
VHOST_LOG_DIR=""
VHOST_ROOT=""
VHOST_ROOT_DIR=""

# Set the arguments of the file.
for arg in "${@}"; do
  case "${arg}" in
  --vhostname=*)
    VHOST_NAME="$(echo "${arg}" | sed -E 's/(--vhostname=)//')"
    ;;
  --vhostroot=*)
    VHOST_ROOT="$(echo "${arg}" | sed -E 's/(--vhostroot=)//')"
    ;;
  esac
done

# Set regex pattern.
SPACE0='[\t ]{0,}'
SPACE1='[\t ]{1,}'

# Import variables from the env file.
PUBLIC_IP="$(getPkgCnf -rs="\[HOSTS\]" -fs="=" -s="PUBLIC_IP")"

# Adding virtual host name to the /etc/hosts file.
if [ ! -z "${VHOST_NAME}" ]; then
  if [ -z "$(cat "/etc/hosts" | egrep "^${PUBLIC_IP}${SPACE1}${VHOST_NAME}$")" ]; then
    sed -i "2 a\\${PUBLIC_IP} ${VHOST_NAME}" /etc/hosts
  fi
fi

# Vhosting root directory settings.
if [ -z "${VHOST_NAME}" ]; then
  VHOST_DIR="/var/www/html"
else
  VHOST_DIR="/var/www/${VHOST_NAME}"
fi

# Vhosting log directory settings.
VHOST_LOG_DIR="${VHOST_DIR}/logs"

if [ ! -d "${VHOST_LOG_DIR}" ]; then
  mkdir -p "${VHOST_LOG_DIR}"
fi

# Vhosting document directory settings.
if [ -z "${VHOST_ROOT}" ]; then
  VHOST_ROOT_DIR="/var/www/${VHOST_NAME}/html"
else
  VHOST_ROOT_DIR="/var/www/${VHOST_NAME}/html/${VHOST_ROOT}"
fi
VHOST_ROOT_DIR="$(echo "${VHOST_ROOT_DIR}" | sed -E -e 's/\/+/\//g' -e 's/\/+$//g')"

if [ ! -d "${VHOST_ROOT_DIR}" ]; then
  mkdir -p "${VHOST_ROOT_DIR}"
fi

# Setting directory permissions.
chown -R www-data:www-data "${VHOST_DIR}"
chmod -R 775 "${VHOST_DIR}"

# Escape String.
ESCAPE_VHOST_NAME="$(escapeString "${VHOST_NAME}")"
ESCAPE_VHOST_ROOT_DIR="$(escapeString "${VHOST_ROOT_DIR}")"
ESCAPE_VHOST_LOG_DIR="$(escapeString "${VHOST_LOG_DIR}")"

#
# HTTP: 80 port
# Creating new vhosting files
f_80="/etc/apache2/sites-available/${VHOST_NAME}.conf"

if [ -f ".${f_80}" ]; then
  cp -v ".${f_80}" "${f_80}"
else

  cat >"${f_80}" <<VHOSTCONFSCRIPT
$(cat "${ABSPKG}/tmpl/vhost.conf")
VHOSTCONFSCRIPT

  sed -i -E \
    -e "s/VHOST_NAME/${ESCAPE_VHOST_NAME}/" \
    -e "s/VHOST_ROOT_DIR/${ESCAPE_VHOST_NAME}/" \
    -e "s/VHOST_LOG_DIR/${ESCAPE_VHOST_NAME}/" \
    "${f_80}"

fi

#
# HTTPS: 443 port
# Apache2 configuration in env file.
PROTO="$(getPkgCnf -rs="\[HOSTS\]" -fs="=" -s="PROTO")"

# Creating new SSL vhosting files
if [ "${PROTO^^}" == "HTTPS" ]; then

  f_443="/etc/apache2/sites-available/${VHOST_NAME}-ssl.conf"

  if [ -f ".${f_443}" ]; then
    cp -v ".${f_443}" "${f_443}"
  else

    cat >"${f_443}" <<VHOSTCONFSCRIPT
$(cat "${ABSPKG}/tmpl/vhost-ssl.conf")
VHOSTCONFSCRIPT

    sed -i -E \
      -e "s/VHOST_NAME/${ESCAPE_VHOST_NAME}/" \
      -e "s/VHOST_ROOT_DIR/${ESCAPE_VHOST_NAME}/" \
      -e "s/VHOST_LOG_DIR/${ESCAPE_VHOST_NAME}/" \
      "${f_443}"

  fi

fi

# Disabling default vhosting
if [ ! -z "$(a2query -s | awk '{print $1}' | egrep "^000-default$")" ]; then
  cd /etc/apache2/sites-available
  a2dissite 000-default.conf
fi

# Enabling new vhosting
if [ -z "$(a2query -s | awk '{print $1}' | egrep "^${VHOST_NAME}$")" ]; then
  cd /etc/apache2/sites-available
  a2ensite "${VHOST_NAME}.conf"
fi

if [ "${PROTO}" == "https" ]; then

  # Disabling default SSL vhosting
  if [ ! -z "$(a2query -s | awk '{print $1}' | egrep "^000-default-ssl$")" ]; then
    cd /etc/apache2/sites-available
    a2dissite 000-default-ssl.conf
  fi

  # Enabling new ssl vhosting
  if [ -z "$(a2query -s | awk '{print $1}' | egrep "^${VHOST_NAME}-ssl$")" ]; then
    cd /etc/apache2/sites-available
    a2ensite "${VHOST_NAME}-ssl.conf"
  fi

fi

# Reloading the service
systemctl reload apache2

echo
echo "${PKGNAME^} configuration is complete."
