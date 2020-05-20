#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/virtualhost/wizard.sh
# ./ubuntu/18.04/virtualhost/wizard.sh

# Work even if somebody does "sh thisscript.sh".
set -e

# Set constants in the file.
ENVPATH=""
ABSPATH=""
DIRNAME=""
OS_PATH=""
PKGNAME=""

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
  esac
done

# Include the file.
source "${OS_PATH}/utils.sh"
source "${OS_PATH}/functions.sh"
source "${DIRNAME}/functions.sh"

# Make sure the package is installed.
pkgAudit "apache2"

# Run the command wizard.
COMMANDS=(
  "Create a database?"
  "Are you sure you want to delete the database and user?"
  "quit"
)

echo
IFS=$'\n'
PS3="Please select one of the options. (1-${#COMMANDS[@]}): "
select COMMAND in ${COMMANDS[@]}; do
  case "${COMMAND}" in
  "${COMMANDS[0]}")
    echo
    DBNAME=""
    while [ -z "${DBNAME}" ]; do
      DBNAME="$(msg -yn -p1='Enter the database name: ' -p2='Are you sure you want to save this? (y/n) ')"
      if [ -z "$(mysql -u root -e 'SELECT db FROM mysql.db;' | egrep "^${DBNAME}$")" ] ||
        [ -z "$(mysql -u root -e 'SELECT User FROM mysql.user;' | egrep "^${DBNAME}$")" ]; then
        echo "${DBNAME} does not exists."
        DBNAME=""
      fi
    done
    FILENAME="database.sh"
    FILEPATH="${DIRNAME}/${FILENAME}"
    if [ -f "${FILEPATH}" ]; then
      bash "${FILEPATH}" --dbname="${DBNAME}" --ENVPATH="${ENVPATH}" --ABSPATH="${FILEPATH}" --create
    fi
    ;;
  "${COMMANDS[1]}")
    echo
    DBNAME=""
    while [ -z "${DBNAME}" ]; do
      DBNAME="$(msg -yn -p1='Enter the database name: ' -p2='Are you sure you want to save this? (y/n) ')"
      if [ -z "$(mysql -u root -e 'SELECT db FROM mysql.db;' | egrep "^${DBNAME}$")" ] ||
        [ -z "$(mysql -u root -e 'SELECT User FROM mysql.user;' | egrep "^${DBNAME}$")" ]; then
        echo "${DBNAME} does not exists."
        DBNAME=""
      fi
    done
    FILENAME="database.sh"
    FILEPATH="${DIRNAME}/${FILENAME}"
    if [ -f "${FILEPATH}" ]; then
      bash "${FILEPATH}" --dbname="${DBNAME}" --ENVPATH="${ENVPATH}" --ABSPATH="${FILEPATH}" --delete
    fi
    ;;
  "${COMMANDS[2]}")
    exit 0
    ;;
  esac
done
