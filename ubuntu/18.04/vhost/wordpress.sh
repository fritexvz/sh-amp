#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/vhost/wordpress.sh
# ./ubuntu/18.04/vhost/wordpress.sh

# Work even if somebody does "sh thisscript.sh".
set -e

echo
echo "Start installing wordpress."

VHOST_NAME=""
VHOST_DIR="/var/www/html"
VHOST_SUBDIR=""

# Set the arguments.
for arg in "${@}"; do
  case "${arg}" in
  --vhostname=*)
    VHOST_NAME="$(echo "${arg}" | sed -E 's/(--vhostname=)//')"
    VHOST_DIR="/var/www/${VHOST_NAME}/html"
    ;;
  --subdir=*)
    VHOST_SUBDIR="$(echo "${arg}" | sed -E 's/(--subdir=)//')"
    VHOST_DIR="/var/www/${VHOST_NAME}/html/${VHOST_SUBDIR}"
    ;;
  esac
done

# Create a database.
bash ./database.sh --dbname="${VHOST_NAME}"

# Download and extract the latest WordPress.
cd "$(echo "${VHOST_DIR}" | sed -E '{ s#/+#/#g; s#/+$##; }')"

wget https://wordpress.org/latest.zip

unzip latest.zip

rm latest.zip

mv wordpress/* .

rmdir wordpress

echo
echo "Wordpress is completely installed."
