#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/vhost/laravel.sh
# ./ubuntu/18.04/vhost/laravel.sh

# Work even if somebody does "sh thisscript.sh".
set -e

# Set constants in the file.
ENVPATH=""
ABSPATH=""
DIRNAME=""
OS_PATH=""

echo
echo "Start setting up laravel configuration."

VHOST_NAME=""
VHOST_DIR="/var/www/html"
VHOST_SUBDIR=""

# Set the arguments.
for arg in "${@}"; do
  case "${arg}" in
  --ENVPATH=*)
    ENVPATH="$(echo "${arg}" | sed -E 's/(--ENVPATH=)//')"
    ;;
  --ABSPATH=*)
    ABSPATH="$(echo "${arg}" | sed -E 's/(--ABSPATH=)//')"
    DIRNAME="$(dirname "${ABSPATH}")"
    OS_PATH="$(dirname "${DIRNAME}")"
    ;;
  --vhostname=*)
    VHOST_NAME="$(echo "${arg}" | sed -E 's/(--vhostname=)//')"
    VHOST_DIR="/var/www/${VHOST_NAME}/html"
    ;;
  --subdir=*)
    VHOST_SUBDIR="$(echo "${arg}" | sed -E 's/(--subdir=)//')"
    VHOST_DIR="/var/www/${VHOST_NAME}/html/${VHOST_SUBDIR}"
    ;;
  esac
done

sed -i -E \
  -e "/DocumentRoot/{ s#${VHOST_DIR}#${VHOST_DIR}/public#; }" \
  "/etc/apache2/sites-available/${VHOST_NAME}.conf"

sed -i -E \
  -e "/DocumentRoot/{ s#${VHOST_DIR}#${VHOST_DIR}/public#; }" \
  "/etc/apache2/sites-available/${VHOST_NAME}-ssl.conf"

# Reload the service
if [ ! -z "$(isApache2)" ]; then
  systemctl reload apache2
fi

# Download and extract the latest laravel.
cd "$(echo "${VHOST_DIR}" | sed -E '{ s#/+#/#g; s#/+$##; }')"

composer create-project --prefer-dist laravel/laravel .

php artisan serve

# Restart the service
if [ ! -z "$(isApache2)" ]; then
  systemctl restart apache2
fi

echo
echo "Laravel configuration is complete."
