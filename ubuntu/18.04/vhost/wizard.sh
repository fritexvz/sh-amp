#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/vhost/wizard.sh
# ./ubuntu/18.04/vhost/wizard.sh

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
FAQS=(
  "install"
  "uninstall"
  "quit"
)

echo
IFS=$'\n'
PS3="Please select one of the options. (1-${#FAQS[@]}): "
select FAQ in ${FAQS[@]}; do
  case "${FAQ}" in
  "${FAQS[0]}")
    if [ -f install.sh ]; then bash install.sh; fi
    break
    ;;
  "${FAQS[1]}")
    if [ -f uninstall.sh ]; then bash uninstall.sh; fi
    break
    ;;
  "${FAQS[2]}")
    exit 0
    ;;
  esac
done