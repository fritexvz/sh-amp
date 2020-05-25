#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/virtualhost/wp-cli.sh
# ./ubuntu/18.04/virtualhost/wp-cli.sh
#
# Installation
# https://github.com/wp-cli/wp-cli
# https://make.wordpress.org/cli/handbook/quick-start/

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

echo
echo "Start installing wordpress."

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

# Set the constant in wp-config.
DB_NAME="${VHOST_NAME//[^a-zA-Z0-9_]/}"
DB_NAME="${DB_NAME:0:16}"
DB_USER="${DB_NAME}"
DB_USER="${DB_USER:0:16}"
DB_PASS="$(openssl rand -base64 12)"
DB_PASS="${DB_PASS:0:16}"
DB_HOST="localhost"
DB_CHARSET="$(getPkgCnf -f="/etc/my.cnf" -rs="\[mysqld\]" -fs="=" -s="character-set-server")"
DB_COLLATE="$(getPkgCnf -f="/etc/my.cnf" -rs="\[mysqld\]" -fs="=" -s="collation-server")"
DB_PREFIX="wp_"

# Check if the database and user name exists.
if [ -z "$(isDb "${DB_NAME}")" ] && [ -z "$(isDbUser "${DB_USER}")" ]; then
  create_database "${DB_NAME}" "${DB_USER}" "${DB_PASS}"
else
  echo
  echo "Database ${DB_NAME} already exists."
  DELETE_MESSAGE="$(msg -yn "Are you sure you want to delete the database? (y/n) ")"
  if [ "${DELETE_MESSAGE}" == "Yes" ]; then
    delete_database "${DB_NAME}" "${DB_USER}"
    create_database "${DB_NAME}" "${DB_USER}" "${DB_PASS}"
  fi
fi

# Import variables from the env file.
PROTO="$(getPkgCnf -rs="\[HOSTS\]" -fs="=" -s="PROTO")"

# Set WordPress parameters.
SITE_TITLE="SiteTitle"
ADMIN_USER="admin"
ADMIN_PASSWORD="123456"
ADMIN_EMAIL="$(msg -yn -c "admin_email: ")"

# Download and extract the latest WordPress.
cd "${VHOST_ROOT_DIR}"

wp core download --allow-root
wp core config --allow-root --dbname="${DB_NAME}" --dbuser="${DB_USER}" --dbpass="${DB_PASS}" --dbhost="${DB_HOST}" --dbcharset="${DB_CHARSET}" --dbcollate="${DB_COLLATE}" --dbprefix="${DB_PREFIX}"
wp core install --allow-root --allow-root --url="${PROTO,,}://${VHOST_NAME}" --title="${SITE_TITLE}" --admin_user="${ADMIN_USER}" --admin_password="${ADMIN_PASSWORD}" --admin_email="${ADMIN_EMAIL}"

echo "title: ${SITE_TITLE}"
echo "admin_user: ${ADMIN_USER}"
echo "admin_password: ${ADMIN_PASSWORD}"
echo "admin_email: ${ADMIN_EMAIL}"

# Change directory permissions.
chown -R www-data:www-data "${VHOST_ROOT_DIR}"
chmod -R 775 "${VHOST_ROOT_DIR}"

# initialize
wp theme delete --all
wp plugin delete --all

echo
echo "Wordpress is completely installed."