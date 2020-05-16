#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/apache2/wizard.sh
# ./ubuntu/18.04/apache2/wizard.sh

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
pkgAudit "${PKGNAME}"

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
    systemctl status apache2
    echo "${PKGNAME^} state loaded."
    ;;
  "${COMMANDS[1]}")
    systemctl start apache2
    echo "${PKGNAME^} started."
    ;;
  "${COMMANDS[2]}")
    systemctl stop apache2
    echo "${PKGNAME^} has stopped."
    ;;
  "${COMMANDS[3]}")
    systemctl reload apache2
    echo "${PKGNAME^} was refreshed."
    ;;
  "${COMMANDS[4]}")
    systemctl restart apache2
    echo "${PKGNAME^} restarted."
    ;;
  "${COMMANDS[5]}")
    systemctl enable apache2
    echo "${PKGNAME^} is enabled."
    ;;
  "${COMMANDS[6]}")
    systemctl disable apache2
    echo "${PKGNAME^} is disabled."
    ;;
  "${COMMANDS[7]}")
    exit 0
    ;;
  esac
done
