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

# Set constants in the file.
ENVPATH=""
ABSPATH=""
DIRNAME=""
OS_PATH=""

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
    ;;
  esac
done

# Include the file.
source "${OS_PATH}/utils.sh"
source "${OS_PATH}/functions.sh"
source "${DIRNAME}/functions.sh"

# Make sure the package is installed.
pkgAudit "mariadb"

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
PS3="Choose the next step. (1-${#FAQS[@]}): "
select FAQ in ${FAQS[@]}; do
  case "${FAQ}" in
  "${FAQS[0]}")
    step="${FAQS[0]}"
    break
    ;;
  "${FAQS[1]}")
    step="${FAQS[1]}"
    break
    ;;
  "${FAQS[2]}")
    step="${FAQS[2]}"
    break
    ;;
  "${FAQS[3]}")
    step="${FAQS[3]}"
    break
    ;;
  "${FAQS[4]}")
    step="${FAQS[4]}"
    break
    ;;
  "${FAQS[5]}")
    step="${FAQS[5]}"
    break
    ;;
  "${FAQS[6]}")
    step="${FAQS[6]}"
    break
    ;;
  "${FAQS[7]}")
    exit 0
    ;;
  esac
done

if [ "${step}" == "status" ]; then
  systemctl status mariadb
fi

if [ "${step}" == "start" ]; then
  systemctl start mariadb
fi

if [ "${step}" == "stop" ]; then
  systemctl stop mariadb
fi

if [ "${step}" == "reload" ]; then
  systemctl reload mariadb
fi

if [ "${step}" == "restart" ]; then
  systemctl restart mariadb
fi

if [ "${step}" == "enable" ]; then
  systemctl enable mariadb
fi

if [ "${step}" == "disable" ]; then
  systemctl disable mariadb
fi
