#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/sendmail/config.sh
# ./ubuntu/18.04/sendmail/config.sh

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

# Make sure the package is installed.
pkgAudit "${PKGNAME}"

echo
echo "Start setting up ${PKGNAME} configuration."

# Set the arguments.
for arg in "${@}"; do
  case $arg in
  --my)
    IFS=$'\n'
    for i in $(find "${ABSPKG}/etc" -type f -name "[^_]*"); do
      cp "$i" "$(echo "$i" | sed "s/${ABSPKG//\//\\/}//")"
    done
    echo "${PKGNAME^} configuration is complete."
    exit 0
    ;;
  esac
done

# Add localhost to your script.
echo "localhost" > /etc/mail/local-host-names

# Restart the service.
systemctl restart sendmail

# Reloading the service.
systemctl reload apache2

echo
echo "${PKGNAME^} configuration is complete."
