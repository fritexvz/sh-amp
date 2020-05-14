#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/vhost/install.sh
# ./ubuntu/18.04/vhost/install.sh

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
pkgAudit "apache2"

echo
echo "Start installing virtualhost."

echo
VHOST_NAME=""
while [ -z "${VHOST_NAME}" ]; do
  VHOST_NAME="$(msg -yn -p1='Enter server name. (ex) example.com : ' -p2='Are you sure you want to save this? (y/n) ')"
  if [ -d "/var/www/${VHOST_NAME}" ]; then
    echo "${VHOST_NAME} already exists."
    if [ "$(msg -yn 'Do you want to overwrite it? (y/n) ')" == "No" ]; then
      VHOST_NAME=""
    fi
  fi
done

# config.sh
if [ -f ./config.sh ]; then
  bash ./config.sh --name="${VHOST_NAME}"
fi

# Wizard
echo
PS3="Choose the next step. (1-6) : "
select choice in "default" "database" "laravel" "wordpress" "laravel+wordpress" "quit"; do
  case "${choice}" in
  "default")
    step="default"
    bash ./default.sh --name="${VHOST_NAME}"
    break
    ;;
  "database")
    step="database"
    bash ./database.sh --name="${VHOST_NAME}"
    break
    ;;
  "laravel")
    step="laravel"
    bash ./laravel.sh --name="${VHOST_NAME}"
    break
    ;;
  "wordpress")
    step="wordpress"
    bash ./wordpress.sh --name="${VHOST_NAME}"
    break
    ;;
  "laravel+wordpress")
    step="laravel+wordpress"
    bash ./laravel.sh --name="${VHOST_NAME}"
    bash ./wordpress.sh --name="${VHOST_NAME}" --subdir="blog"
    break
    ;;
  "quit")
    exit
    ;;
  esac
done

echo
echo "Virtualhost is completely installed."