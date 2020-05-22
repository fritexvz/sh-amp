#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/vhost/wordpress.sh
# ./ubuntu/18.04/vhost/wordpress.sh

# Work even if somebody does "sh thisscript.sh".
set -e

# Set global constants in the file.
ENVPATH=""
ABSPATH=""
DIRNAME=""
OS_PATH=""
PKGNAME=""

# Set virtualhost constants in the file.
VHOST_NAME=""
VHOST_DIR=""
VHOST_ROOT=""
VHOST_ROOT_DIR=""

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
    PKGNAME="$(basename "${DIRNAME,,}")"
    ;;
  --vhostname=*)
    VHOST_NAME="$(echo "${arg}" | sed -E 's/(--vhostname=)//')"
    ;;
  --vhostroot=*)
    VHOST_ROOT="$(echo "${arg}" | sed -E 's/(--vhostroot=)//')"
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
echo "Start installing wordpress."

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

# Download and extract the latest WordPress.
cd "${VHOST_ROOT_DIR}"

wget https://wordpress.org/latest.zip

unzip latest.zip
rm latest.zip
mv wordpress/* .
rmdir wordpress

# Change directory permissions.
chown -R www-data:www-data "${VHOST_ROOT_DIR}"
chmod -R 775 "${VHOST_ROOT_DIR}"

# Create wp-config.php file.
cp "${VHOST_ROOT_DIR}/wp-config-sample.php" "${VHOST_ROOT_DIR}/wp-config.php"
cp "${VHOST_ROOT_DIR}/wp-config.php"{,.bak}

# Set database constants in the file.
DB_NAME="${VHOST_NAME//[^a-zA-Z0-9_]/}"
DB_NAME="${DB_NAME:0:16}"
DB_USER="${DB_NAME}"
DB_USER="${DB_USER:0:16}"
DB_PASSWORD="$(openssl rand -base64 12)"
DB_PASSWORD="${DB_PASSWORD:0:16}"
DB_HOST="localhost"
DB_CHARSET="$(getPkgCnf -f="/etc/my.cnf" -rs="\[mysqld\]" -fs="=" -s="character-set-server")"
DB_COLLATE="$(getPkgCnf -f="/etc/my.cnf" -rs="\[mysqld\]" -fs="=" -s="collation-server")"
TABLE_PREFIX="wp_"

echo
echo "Would you like to install WordPress with the following settings?"
echo "DB_NAME: ${DB_NAME}"
echo "DB_USER: ${DB_USER}"
echo "DB_PASSWORD: ${DB_PASSWORD}"
echo "DB_HOST: ${DB_HOST}"
echo "DB_CHARSET: ${DB_CHARSET}"
echo "DB_COLLATE: ${DB_COLLATE}"
echo "TABLE_PREFIX: ${TABLE_PREFIX}"

CHANGE_MESSAGE="$(msg -yn "Do you want to change it? (y/n) ")"
if [ "${CHANGE_MESSAGE}" == "Yes" ]; then
  NEW_CONFIG=""
  while [ -z "${NEW_CONFIG}" ]; do
    read -p "DB_NAME: " NEW_DB_NAME
    read -p "DB_USER: " NEW_DB_USER
    read -p "DB_PASSWORD: " NEW_DB_PASSWORD
    read -p "DB_HOST: " NEW_DB_HOST
    read -p "DB_CHARSET: " NEW_DB_CHARSET
    read -p "DB_COLLATE: " NEW_DB_COLLATE
    read -p "TABLE_PREFIX: " NEW_TABLE_PREFIX
    SAVE_MESSAGE="$(msg -ync "Do you want to save it? (y/n/c) ")"
    case "${SAVE_MESSAGE}" in
    "Yes")
      DB_NAME="${NEW_DB_NAME//[^a-zA-Z0-9_]/}"
      DB_NAME="${DB_NAME:0:16}"
      DB_USER="${NEW_DB_USER//[^a-zA-Z0-9_]/}"
      DB_USER="${DB_USER:0:16}"
      DB_PASSWORD="${NEW_DB_PASSWORD:0:16}"
      DB_HOST="${NEW_DB_HOST}"
      DB_CHARSET="${NEW_DB_CHARSET}"
      DB_COLLATE="${NEW_DB_COLLATE}"
      TABLE_PREFIX="${NEW_TABLE_PREFIX}"
      NEW_CONFIG="Yes"
      break
      ;;
    "No")
      NEW_CONFIG=""
      ;;
    "Cancel")
      NEW_CONFIG=""
      break
      ;;
    esac
  done
fi

# Check if the database and user name exists.
if [ -z "$(mysql -uroot -e 'SHOW DATABASES;' | egrep "^${DB_NAME}$")" ] &&
  [ -z "$(mysql -uroot -e 'SELECT User FROM mysql.user;' | egrep "^${DB_NAME}$")" ]; then
  create_database "${DB_NAME}" "${DB_USER}" "${DB_PASSWORD}"
else
  echo
  echo "Database ${DB_NAME} already exists."
  REINSTALL_MESSAGE="$(msg -yn "Would you like to reinstall the database? (y/n) ")"
  if [ "${REINSTALL_MESSAGE}" == "Yes" ]; then
    delete_database "${DB_NAME}" "${DB_USER}"
    create_database "${DB_NAME}" "${DB_USER}" "${DB_PASSWORD}"
  fi
fi

sed -i -E \
  -e "s/^(define\([\t ]{0,}'DB_NAME',[\t ]{0,}')(.*)('[\t ]{0,}\))$/\1${DB_NAME}\3/" \
  -e "s/^(define\([\t ]{0,}'DB_USER',[\t ]{0,}')(.*)('[\t ]{0,}\))$/\1${DB_USER}\3/" \
  -e "s/^(define\([\t ]{0,}'DB_PASSWORD',[\t ]{0,}')(.*)('[\t ]{0,}\))$/\1${DB_PASSWORD}\3/" \
  -e "s/^(define\([\t ]{0,}'DB_HOST',[\t ]{0,}')(.*)('[\t ]{0,}\))$/\1${DB_HOST}\3/" \
  -e "s/^(define\([\t ]{0,}'DB_CHARSET',[\t ]{0,}')(.*)('[\t ]{0,}\))$/\1${DB_CHARSET}\3/" \
  -e "s/^(define\([\t ]{0,}'DB_COLLATE',[\t ]{0,}')(.*)('[\t ]{0,}\))$/\1${DB_COLLATE}\3/" \
  -e "s/^(\$table_prefix[\t ]{0,}=[\t ]{0,}')(.*)('\;)$/\1${TABLE_PREFIX}\3/" \
  "${VHOST_ROOT_DIR}/wp-config.php"

# Reloading the service
if [ ! -z "$(isApache2)" ]; then
  systemctl reload apache2
fi

echo
echo "Wordpress is completely installed."
