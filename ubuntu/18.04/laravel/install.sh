#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/laravel/install.sh
# ./ubuntu/18.04/laravel/install.sh

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
source "${ABSPKG}/functions.sh"

# Make sure the package is installed.
pkgAudit "php"

echo
echo "Start installing ${PKGNAME^^}."

# Install laravel installer.
composer global require laravel/installer

# Edit environment config.
# https://stackoverflow.com/questions/28597648/laravel-5-installation-in-ubuntu-laravel-command-not-found

#echo 'export PATH="$PATH:$HOME/.composer/vendor/bin"' >> ~/.bashrc

# Ubuntu 17.04 and 17.10:
#echo 'export PATH="~/.config/composer/vendor/bin:$PATH"' >> ~/.bashrc

# Ubuntu 18.04
echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> ~/.bashrc

# Then reload path config.
source ~/.bashrc

# JavaScript & CSS Scaffolding
composer require laravel/ui

echo
echo "${PKGNAME^^} is completely installed."



