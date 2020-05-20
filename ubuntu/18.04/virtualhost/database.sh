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
DBNAME=""
DBPASS=""
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
    DBNAME="$(echo "${arg}" | sed -E 's/(--dbname=)//')"
    ;;
  --dbpass=*)
    DBPASS="$(echo "${arg}" | sed -E 's/(--dbpass=)//')"
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
if [ -z "${DBNAME}" ]; then
  DBNAME="$(openssl rand -base64 12)"
fi
DBNAME="${DBNAME//[^a-zA-Z0-9_]/}"
DBNAME="${DBNAME:0:16}"

if [ "${STEP}" == "delete" ]; then
  msgYn="$(msg -yn 'Are you sure you want to delete the database? (y/n) ')"
  if [ "${msgYn}" == "Yes" ]; then
    delete_database "${DBNAME}"
  else
    exit 0
  fi
else

  # Check if the database and user name exists.
  if [ ! -z "$(mysql -u root -e 'SELECT db FROM mysql.db;' | egrep "^${DBNAME}$")" ] ||
    [ ! -z "$(mysql -u root -e 'SELECT User FROM mysql.user;' | egrep "^${DBNAME}$")" ]; then
    echo "Database '${DBNAME}' already exists."
    msgYn="$(msg -yn 'Are you sure you want to delete the database? (y/n) ')"
    if [ "${msgYn}" == "Yes" ]; then
      delete_database "${DBNAME}"
    else
      exit 0
    fi
  fi

  # Check the database password.
  if [ -z "${DBPASS}" ]; then
    DBPASS="$(openssl rand -base64 12)"
  fi
  DBPASS="${DBPASS:0:16}"

  # Create a database.
  create_database "${DBNAME}"

  echo "MySQL user created."
  echo "Username: ${DBNAME}"
  echo "Password: ${DBPASS}"

fi

echo
echo "Database is completely installed."
