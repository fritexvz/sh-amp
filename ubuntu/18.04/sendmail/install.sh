#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/sendmail/install.sh
# ./ubuntu/18.04/sendmail/install.sh

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

echo
echo "Start installing ${PKGNAME}."

# Make sure the package is installed.
if [ ! -z "$(is${PKGNAME^})" ]; then
  CONFIRM_MESSAGE="$(msg -yn "The ${PKGNAME} package is already installed. Would you like to reinstall?")"
  if [ CONFIRM_MESSAGE == "No" ]; then
    exit 0
  fi
fi

apt -y install sendmail

# Start the package and set it to start on boot.
pkgOnBoot "sendmail"

# Reloading the service.
systemctl reload apache2

# Create a backup file.
cp -v /etc/mail/local-host-names{,.bak}

# Add a variable to the env file.
addPkgCnf -rs="\[SENDMAIL\]" -fs="=" -o="<<HERE
SENDMAIL_VERSION = $(getSendmailVer)
<<HERE"

echo
echo "${PKGNAME^} is completely installed."
