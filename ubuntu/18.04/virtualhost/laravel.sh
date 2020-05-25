#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/virtualhost/laravel.sh
# ./ubuntu/18.04/virtualhost/laravel.sh

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
echo "Start setting up laravel configuration."

# Set constants.
VHOST_NAME=""
VHOST_DIR=""
VHOST_ROOT=""
VHOST_ROOT_DIR=""

# Set the arguments.
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

# Vhosting root directory settings.
if [ -z "${VHOST_NAME}" ]; then
  VHOST_DIR="/var/www/html"
else
  VHOST_DIR="/var/www/${VHOST_NAME}/html"
fi

# Vhosting document directory settings.
if [ -z "${VHOST_ROOT}" ]; then
  VHOST_ROOT_DIR="${VHOST_DIR}"
else
  VHOST_ROOT_DIR="${VHOST_DIR}/${VHOST_ROOT}"
fi
VHOST_ROOT_DIR="$(echo "${VHOST_ROOT_DIR}" | sed -E -e 's/\/+/\//g' -e 's/\/+$//g')"

# Setting up vhosting directory
if [ ! -d "${VHOST_ROOT_DIR}" ]; then
  mkdir -p "${VHOST_ROOT_DIR}"
fi

# Download and extract the latest laravel.
cd "${VHOST_ROOT_DIR}"

laravel new .

npm install && npm run dev

# Set a database.
CREATE_DB="No"
if [ "${CREATE_DB}" == "No" ]; then
  sed -i -E -e '/^DB_(.*)=/{ s/^/#/; s/^#+/#/; }' .env
else
  sed -i -E -e 's/(DB_CONNECTION=)(.*)/\1(mysql)/' .env
  sed -i -E -e 's/(DB_HOST=)(.*)/\1(127.0.0.1)/' .env
  sed -i -E -e 's/(DB_PORT=)(.*)/\1(3306)/' .env
  sed -i -E -e 's/(DB_DATABASE=)(.*)/\1(laravel)/' .env
  sed -i -E -e 's/(DB_USERNAME=)(.*)/\1(root)/' .env
  sed -i -E -e 's/(DB_PASSWORD=)(.*)/\1(password)/' .env
fi

# Change directory permissions.
chown -R www-data:www-data "${VHOST_ROOT_DIR}"
chmod -R 775 "${VHOST_ROOT_DIR}"

php artisan serve

# Reloading the service
systemctl reload apache2

echo
echo "Laravel configuration is complete."
