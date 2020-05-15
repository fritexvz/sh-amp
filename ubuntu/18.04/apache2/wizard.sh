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
FAQS=(
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
PS3="Please select one of the options. (1-${#FAQS[@]}): "
select FAQ in ${FAQS[@]}; do
  case "${FAQ}" in
  "${FAQS[0]}")
    systemctl status apache2
    echo "${PKGNAME^} state loaded."
    ;;
  "${FAQS[1]}")
    systemctl start apache2
    echo "${PKGNAME^} started."
    ;;
  "${FAQS[2]}")
    systemctl stop apache2
    echo "${PKGNAME^} has stopped."
    ;;
  "${FAQS[3]}")
    systemctl reload apache2
    echo "${PKGNAME^} was refreshed."
    ;;
  "${FAQS[4]}")
    systemctl restart apache2
    echo "${PKGNAME^} restarted."
    ;;
  "${FAQS[5]}")
    systemctl enable apache2
    echo "${PKGNAME^} is enabled."
    ;;
  "${FAQS[6]}")
    systemctl disable apache2
    echo "${PKGNAME^} is disabled."
    ;;
  "${FAQS[7]}")
    exit 0
    ;;
  esac
done
