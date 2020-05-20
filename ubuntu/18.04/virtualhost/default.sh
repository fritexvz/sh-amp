#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/vhost/default.sh
# ./ubuntu/18.04/vhost/default.sh

# Work even if somebody does "sh thisscript.sh".
set -e

# Set constants in the file.
ENVPATH=""
ABSPATH=""
DIRNAME=""
OS_PATH=""

echo
echo "Start installing default template."

VHOST_NAME=""
VHOST_DIR="/var/www/html"
VHOST_SUBDIR=""

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
    ;;
  --vhostname=*)
    VHOST_NAME="$(echo "${arg}" | sed -E 's/(--vhostname=)//')"
    VHOST_DIR="$(echo "/var/www/${VHOST_NAME}/html" | sed -E -e 's#/+#/#g' -e 's#/+$##')"
    ;;
  --subdir=*)
    VHOST_SUBDIR="$(echo "${arg}" | sed -E 's/(--subdir=)//')"
    VHOST_DIR="$(echo "/var/www/${VHOST_NAME}/html/${VHOST_SUBDIR}" | sed -E -e 's#/+#/#g' -e 's#/+$##')"
    ;;
  esac
done

cp -v "/var/www/html/index.html" "${VHOST_DIR}/index.html"

echo
echo "Default template is completely installed."
