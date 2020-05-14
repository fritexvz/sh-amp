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

echo
echo "Start installing default html."

VHOST_NAME=""

# Set the arguments.
for arg in "${@}"; do
  case "${arg}" in
  --name=*)
    VHOST_NAME="$(echo "${arg}" | sed -E 's/(--name=)//')"
    ;;
  esac
done

cp -v "/var/www/html/index.html" "/var/www/${VHOST_NAME}/html/index.html"

echo
echo "Default html is completely installed."
