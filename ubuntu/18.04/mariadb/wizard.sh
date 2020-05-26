#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/mariadb/wizard.sh
# ./ubuntu/18.04/mariadb/wizard.sh

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
pkgAudit "${PKGNAME}"

echo
echo "Start the ${PKGNAME} wizard."

# Run the command wizard.
COMMANDS=(
  "status"
  "start"
  "stop"
  "reload"
  "restart"
  "enable"
  "disable"
  "quit"
)
echo
IFS=$'\n'
PS3="Please select one of the options. (1-${#COMMANDS[@]}): "
select COMMAND in ${COMMANDS[@]}; do
  case "${COMMAND}" in
  "${COMMANDS[0]}")
    systemctl status mariadb
    echo "${PKGNAME^} state loaded."
    ;;
  "${COMMANDS[1]}")
    systemctl start mariadb
    echo "${PKGNAME^} started."
    ;;
  "${COMMANDS[2]}")
    systemctl stop mariadb
    echo "${PKGNAME^} has stopped."
    ;;
  "${COMMANDS[3]}")
    systemctl reload mariadb
    echo "${PKGNAME^} was refreshed."
    ;;
  "${COMMANDS[4]}")
    systemctl restart mariadb
    echo "${PKGNAME^} restarted."
    ;;
  "${COMMANDS[5]}")
    systemctl enable mariadb
    echo "${PKGNAME^} is enabled."
    ;;
  "${COMMANDS[6]}")
    systemctl disable mariadb
    echo "${PKGNAME^} is disabled."
    ;;
  "${COMMANDS[7]}")
    exit 0
    ;;
  esac
done

echo
echo "Exit the ${PKGNAME} wizard."
