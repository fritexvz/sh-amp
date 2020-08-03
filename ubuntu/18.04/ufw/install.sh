#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/ufw/install.sh
# ./ubuntu/18.04/ufw/install.sh

# Work even if somebody does "sh thisscript.sh".
set -e

# Set a relative path.
FILENAME="$(basename $0)"
PKGPATH="$(dirname $0)"
PKGNAME="$(basename "${PKGPATH}")"
OSPATH="$(dirname "${PKGPATH}")"
LIBPATH="${PKGPATH}/lib"
TMPLPATH="${PKGPATH}/tmpl"

# Set absolute path.
ABSROOT="$(cd "$(dirname "")" && pwd)"
ABSENV="${ABSROOT}/env"
ABSOS="${ABSROOT}/${OSPATH}"
ABSPKG="${ABSOS}/${PKGNAME}"
ABSLIB="${ABSPKG}/lib"
ABSTMPL="${ABSPKG}/tmpl"
ABSPATH="${ABSPKG}/${FILENAME}"

# Include the file.
source "${ABSOS}/constants.sh"
source "${ABSOS}/utils.sh"
source "${ABSOS}/functions.sh"

echo
echo "Start installing ${PKGNAME}."

# Make sure the package is installed.
if [ ! -z "$(is${PKGNAME^})" ]; then
  CONFIRM_MESSAGE="$(msg -yn "The ${PKGNAME} package is already installed. Would you like to reinstall? (y/n) ")"
  if [ CONFIRM_MESSAGE == "No" ]; then
    exit 0
  fi
fi

apt -y install ufw

# Reload the service.
systemctl reload apache2

# Add a variable to the env file.
setPkgCnf -rs="\[UFW\]" -fs="=" -o="<<HERE
UFW_VERSION = $(getUfwVer)
<<HERE"

echo
echo "${PKGNAME^} is completely installed."
