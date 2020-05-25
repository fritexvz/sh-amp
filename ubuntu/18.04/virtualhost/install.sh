#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/virtualhost/install.sh
# ./ubuntu/18.04/virtualhost/install.sh

# Work even if somebody does "sh thisscript.sh".
set -e

# Set constants.
OSPATH="$(dirname "$(dirname $0)")"
PKGNAME="$(basename "$(dirname $0)")"
FILENAME="$(basename $0)"

# Set directory path.
ABSROOT="${1#*=}"
ABSENV="${ABSROOT}/env"
ABSOS="${ABSROOT}/${OSPATH}"
ABSPKG="${ABSOS}/${PKGNAME}"
ABSPATH="${ABSPKG}/${FILENAME}"

# Include the file.
source "${ABSOS}/utils.sh"
source "${ABSOS}/functions.sh"
source "${ABSPKG}/functions.sh"

# Make sure the package is installed.
pkgAudit "apache2"

echo
echo "Start installing ${VHOST_NAME}."

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
    bash "${ABSPKG}/config.sh" --ABSROOT="${ABSROOT}" --vhostname="${VHOST_NAME}"
    bash "${ABSPKG}/default.sh" --ABSROOT="${ABSROOT}" --vhostname="${VHOST_NAME}"
    break
    ;;
  "${COMMANDS[1]}")
    bash "${ABSPKG}/config.sh" --ABSROOT="${ABSROOT}" --vhostname="${VHOST_NAME}" --vhostroot="/public"
    bash "${ABSPKG}/laravel.sh" --ABSROOT="${ABSROOT}" --vhostname="${VHOST_NAME}"
    break
    ;;
  "${COMMANDS[2]}")
    bash "${ABSPKG}/config.sh" --ABSROOT="${ABSROOT}" --vhostname="${VHOST_NAME}"
    bash "${ABSPKG}/wp-cli.sh" --ABSROOT="${ABSROOT}" --vhostname="${VHOST_NAME}"
    break
    ;;
  "${COMMANDS[3]}")
    bash "${ABSPKG}/config.sh" --ABSROOT="${ABSROOT}" --vhostname="${VHOST_NAME}" --vhostroot="/public"
    bash "${ABSPKG}/laravel.sh" --ABSROOT="${ABSROOT}" --vhostname="${VHOST_NAME}"
    bash "${ABSPKG}/wordpress.sh" --ABSROOT="${ABSROOT}" --vhostname="${VHOST_NAME}" --vhostroot="/blog"
    break
    ;;
  "${COMMANDS[4]}")
    exit
    ;;
  esac
done

echo
echo "The ${VHOST_NAME} is completely installed."
