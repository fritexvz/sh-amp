#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/vhost/database.sh
# ./ubuntu/18.04/vhost/database.sh

# Work even if somebody does "sh thisscript.sh".
set -e

# Set global constants in the file.
ENVPATH=""
ABSPATH=""
DIRNAME=""
OS_PATH=""
PKGNAME=""

# Set databse constants in the file.
DB_NAME=""
DB_USER=""
DB_PASS=""
STEP=""

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
  --dbname=*)
    DB_NAME="$(echo "${arg}" | sed -E 's/(--dbname=)//')"
    ;;
  --dbuser=*)
    DB_USER="$(echo "${arg}" | sed -E 's/(--dbuser=)//')"
    ;;
  --dbpass=*)
    DB_PASS="$(echo "${arg}" | sed -E 's/(--dbpass=)//')"
    ;;
  --create)
    STEP="${arg//--/}"
    ;;
  --delete)
    STEP="${arg//--/}"
    ;;
  esac
done

# Include the file.
source "${OS_PATH}/utils.sh"
source "${OS_PATH}/functions.sh"
source "${DIRNAME}/functions.sh"

# Make sure the package is installed.
pkgAudit "mariadb"

echo
echo "Start installing database."

# Check the database name.
if [ -z "${DB_NAME}" ]; then
  DB_NAME="$(openssl rand -base64 12)"
fi
DB_NAME="${DB_NAME//[^a-zA-Z0-9_]/}"
DB_NAME="${DB_NAME:0:16}"

# Check the user name.
if [ -z "${DB_USER}" ]; then
  DB_USER="${DB_NAME}"
fi
DB_USER="${DB_USER//[^a-zA-Z0-9_]/}"
DB_USER="${DB_USER:0:16}"

# Check the database password.
if [ -z "${DB_PASS}" ]; then
  DB_PASS="$(openssl rand -base64 12)"
fi
DB_PASS="${DB_PASS:0:16}"

if [ "${STEP}" == "delete" ]; then
  msgYn="$(msg -yn 'Are you sure you want to delete the database? (y/n) ')"
  if [ "${msgYn}" == "Yes" ]; then
    delete_database "${DB_NAME}" "${DB_USER}"
  else
    exit 0
  fi
else

  # Check if the database and user name exists.
  if [ ! -z "$(mysql -u root -e 'SELECT db FROM mysql.db;' | egrep "^${DB_NAME}$")" ] ||
    [ ! -z "$(mysql -u root -e 'SELECT User FROM mysql.user;' | egrep "^${DB_NAME}$")" ]; then
    echo "Database '${DB_NAME}' already exists."
    msgYn="$(msg -yn 'Are you sure you want to delete the database? (y/n) ')"
    if [ "${msgYn}" == "Yes" ]; then
      delete_database "${DB_NAME}" "${DB_USER}"
    else
      exit 0
    fi
  fi

  # Create a database.
  create_database "${DB_NAME}" "${DB_USER}" "${DB_PASS}"
  
fi

echo
echo "Database is completely installed."
