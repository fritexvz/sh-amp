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

# Set global constants.
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

echo
VHOST_NAME=""
while [ -z "${VHOST_NAME}" ]; do
  VHOST_NAME="$(msg -yn -c "Enter the domain name. (ex) example.com : ")"
  if [ -d "/var/www/${VHOST_NAME}" ]; then
    echo "${VHOST_NAME} already exists."
    REINSTALL_MESSAGE="$(msg -yn "Would you like to reinstall? (y/n) ")"
    if [ "${REINSTALL_MESSAGE}" == "No" ]; then
      VHOST_NAME=""
    else
      rm -rf "/var/www/${VHOST_NAME}/html"
    fi
  fi
done

# Setting up vhosting directory
if [ ! -d "/var/www/${VHOST_NAME}/html" ]; then
  mkdir -p "/var/www/${VHOST_NAME}/html"
fi

echo
echo "Start installing ${VHOST_NAME}."

# Run the command wizard.
COMMANDS=(
  "default"
  "laravel"
  "wordpress"
  "laravel+wordpress"
  "quit"
)

echo
IFS=$'\n'
PS3="Please select one of the options. (1-${#COMMANDS[@]}): "
select COMMAND in ${COMMANDS[@]}; do
  case "${COMMAND}" in
  "${COMMANDS[0]}")
    bash "${DIRNAME}/config.sh" --ENVPATH="${ENVPATH}" --ABSPATH="${DIRNAME}/config.sh" --vhostname="${VHOST_NAME}"
    bash "${DIRNAME}/default.sh" --ENVPATH="${ENVPATH}" --ABSPATH="${DIRNAME}/default.sh" --vhostname="${VHOST_NAME}"
    break
    ;;
  "${COMMANDS[1]}")
    bash "${DIRNAME}/config.sh" --ENVPATH="${ENVPATH}" --ABSPATH="${DIRNAME}/config.sh" --vhostname="${VHOST_NAME}" --vhostroot="/public"
    bash "${DIRNAME}/laravel.sh" --ENVPATH="${ENVPATH}" --ABSPATH="${DIRNAME}/laravel.sh" --vhostname="${VHOST_NAME}"
    break
    ;;
  "${COMMANDS[2]}")
    bash "${DIRNAME}/config.sh" --ENVPATH="${ENVPATH}" --ABSPATH="${DIRNAME}/config.sh" --vhostname="${VHOST_NAME}"
    bash "${DIRNAME}/wordpress.sh" --ENVPATH="${ENVPATH}" --ABSPATH="${DIRNAME}/wordpress.sh" --vhostname="${VHOST_NAME}"
    break
    ;;
  "${COMMANDS[3]}")
    bash "${DIRNAME}/config.sh" --ENVPATH="${ENVPATH}" --ABSPATH="${DIRNAME}/config.sh" --vhostname="${VHOST_NAME}" --vhostroot="/public"
    bash "${DIRNAME}/laravel.sh" --ENVPATH="${ENVPATH}" --ABSPATH="${DIRNAME}/laravel.sh" --vhostname="${VHOST_NAME}"
    bash "${DIRNAME}/wordpress.sh" --ENVPATH="${ENVPATH}" --ABSPATH="${DIRNAME}/wordpress.sh" --vhostname="${VHOST_NAME}" --vhostroot="/blog"
    break
    ;;
  "${COMMANDS[4]}")
    exit
    ;;
  esac
done

echo
echo "The ${VHOST_NAME} is completely installed."
