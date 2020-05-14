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
source "functions.sh"

# Make sure the package is installed.
pkgAudit "apache2"

# Run the command wizard.
echo
PS3="Choose the next step. (1-3) : "
select choice in "install" "uninstall" "quit"; do
  case "${choice}" in
  "install")
    if [ -f install.sh ]; then bash install.sh; fi
    break
    ;;
  "uninstall")
    if [ -f uninstall.sh ]; then bash uninstall.sh; fi
    break
    ;;
  "quit")
    exit
    ;;
  esac
done
