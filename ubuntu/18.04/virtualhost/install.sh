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

# Setting up vhosting directory
if [ ! -d "/var/www/${VHOST_NAME}/html" ]; then
  mkdir -p "/var/www/${VHOST_NAME}/html"
fi

echo
echo "Start installing ${VHOST_NAME}."

# config.sh
FILENAME="config.sh"
FILEPATH="${DIRNAME}/${FILENAME}"
if [ -f "${FILEPATH}" ]; then
  bash "${FILEPATH}" --vhostname="${VHOST_NAME}" --ENVPATH="${ENVPATH}" --ABSPATH="${FILEPATH}"
fi

# Wizard
COMMANDS=(
  "default"
  "database"
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
    FILENAME="default.sh"
    FILEPATH="${DIRNAME}/${FILENAME}"
    bash "${FILEPATH}" --vhostname="${VHOST_NAME}" --ENVPATH="${ENVPATH}" --ABSPATH="${FILEPATH}"
    break
    ;;
  "${COMMANDS[1]}")
    FILENAME="database.sh"
    FILEPATH="${DIRNAME}/${FILENAME}"
    bash "${FILEPATH}" --dbname="${VHOST_NAME}" --ENVPATH="${ENVPATH}" --ABSPATH="${FILEPATH}"
    break
    ;;
  "${COMMANDS[2]}")
    FILENAME="laravel.sh"
    FILEPATH="${DIRNAME}/${FILENAME}"
    bash "${FILEPATH}" --vhostname="${VHOST_NAME}" --ENVPATH="${ENVPATH}" --ABSPATH="${FILEPATH}" --subdir="laravel"
    break
    ;;
  "${COMMANDS[3]}")
    FILENAME="wordpress.sh"
    FILEPATH="${DIRNAME}/${FILENAME}"
    bash "${FILEPATH}" --vhostname="${VHOST_NAME}" --ENVPATH="${ENVPATH}" --ABSPATH="${FILEPATH}" --subdir="wordpress"
    break
    ;;
  "${COMMANDS[4]}")
    # step1
    FILENAME="laravel.sh"
    FILEPATH="${DIRNAME}/${FILENAME}"
    bash "${FILEPATH}" --vhostname="${VHOST_NAME}" --ENVPATH="${ENVPATH}" --ABSPATH="${FILEPATH}" --subdir="laravel"
    # step2
    FILENAME="wordpress.sh"
    FILEPATH="${DIRNAME}/${FILENAME}"
    bash "${FILEPATH}" --vhostname="${VHOST_NAME}" --ENVPATH="${ENVPATH}" --ABSPATH="${FILEPATH}" --subdir="laravel/blog"
    break
    ;;
  "${COMMANDS[5]}")
    exit
    ;;
  esac
done

echo
echo "The ${VHOST_NAME} is completely installed."
