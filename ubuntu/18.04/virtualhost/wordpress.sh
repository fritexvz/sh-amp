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

# Set global constants in the file.
ENVPATH=""
ABSPATH=""
DIRNAME=""
OS_PATH=""

# Set virtualhost constants in the file.
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

# Include the file.
source "${OS_PATH}/utils.sh"
source "${OS_PATH}/functions.sh"
source "${DIRNAME}/functions.sh"

echo
echo "Start installing wordpress."

# Setting up vhosting directory
if [ ! -d "${VHOST_DIR}" ]; then
  mkdir -p "${VHOST_DIR}"
fi

# Create a database.
FILENAME="database.sh"
FILEPATH="${DIRNAME}/${FILENAME}"
if [ -f "${FILEPATH}" ]; then
  bash "${FILEPATH}" --dbname="${VHOST_NAME}" --ENVPATH="${ENVPATH}" --ABSPATH="${FILEPATH}" --create
fi

# Download and extract the latest WordPress.
cd "${VHOST_DIR}"

wget https://wordpress.org/latest.zip

unzip latest.zip

rm latest.zip

mv wordpress/* .

rmdir wordpress

echo
echo "Wordpress is completely installed."
