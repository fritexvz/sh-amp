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

echo
echo "Start installing database."

DBNAME=""
DBPASS=""

# Set the arguments.
for arg in "${@}"; do
  case "${arg}" in
  --dbname=*)
    DBNAME="$(echo "${arg}" | sed -E 's/(--dbname=)//')"
    ;;
  --dbpass=*)
    DBPASS="$(echo "${arg}" | sed -E 's/(--dbpass=)//')"
    ;;
  esac
done

# Check the database name.
if [ -z "${DBNAME}" ]; then
  DBNAME="$(openssl rand -base64 12)"
fi
DBNAME="${DBNAME//[^a-zA-Z0-9_]/}"
DBNAME="${DBNAME:0:16}"

# Check the database password.
if [ -z "${DBPASS}" ]; then
  DBPASS="$(openssl rand -base64 12)"
fi
DBPASS="${DBPASS:0:16}"

# Create a database.
mysql -uroot <<MYSQL_SCRIPT
CREATE DATABASE ${DBNAME};
CREATE USER '${DBNAME}'@'localhost' IDENTIFIED BY '${DBPASS}';
GRANT ALL PRIVILEGES ON ${DBNAME}.* TO '${DBNAME}'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "MySQL user created."
echo "Username: ${DBNAME}"
echo "Password: ${DBPASS}"

echo
echo "Database is completely installed."
