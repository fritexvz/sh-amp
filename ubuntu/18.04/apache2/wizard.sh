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
OS_PATH=""

# Set the arguments of the file.
for arg in "${@}"; do
  case "${arg}" in
  --ENVPATH=*)
    ENVPATH="$(echo "${arg}" | sed -E 's/(--ENVPATH=)//')"
    ;;
  --ABSPATH=*)
    ABSPATH="$(echo "${arg}" | sed -E 's/(--ABSPATH=)//')"
    OS_PATH="$(dirname "$(dirname "${ABSPATH}")")"
    ;;
  esac
done

# Include the file.
source "${OS_PATH}/utils.sh"
source "${OS_PATH}/functions.sh"
source "./functions.sh"

# Make sure the package is installed.
pkgAudit "apache2"

# Run the command wizard.
echo
PS3="Choose the next step. (1-6): "
select choice in "status" "start" "stop" "reload" "restart" "quit"; do
  case "${choice}" in
  "status")
    step="status"
    break
    ;;
  "start")
    step="start"
    break
    ;;
  "stop")
    step="stop"
    break
    ;;
  "reload")
    step="reload"
    break
    ;;
  "restart")
    step="restart"
    break
    ;;
  "quit")
    exit
    ;;
  esac
done

if [ "${step}" == "status" ]; then
  systemctl status apache2
fi

if [ "${step}" == "start" ]; then
  systemctl start apache2
fi

if [ "${step}" == "stop" ]; then
  systemctl stop apache2
fi

if [ "${step}" == "reload" ]; then
  systemctl reload apache2
fi

if [ "${step}" == "restart" ]; then
  systemctl restart apache2
fi
