#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/host/config.sh
# ./ubuntu/18.04/host/config.sh

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

echo
echo "Set the host name."

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

# Make sure the hostname is changed.
CHANGE_MESSAGE="$(msg -yn "Do you want to change host name? (y/n) ")"

if [ "${CHANGE_MESSAGE}" == "No" ]; then
  exit 0
fi

# Set the host name
HOST_NAME="$(msg -yn -c "hostname or FQDN (ex) example.com : ")"

if [ hostname != "${HOST_NAME}" ]; then
  hostnamectl set-hostname "${HOST_NAME}"
fi

if [ -z "$(cat /etc/hosts | egrep "127.0.1.1 ${HOST_NAME}")" ]; then
  sed -i -e "1 a\127.0.1.1 ${HOST_NAME}" /etc/hosts
fi

# This will cause the set and update hostname module to not operate (if true)
sed -i -E -e '/preserve_hostname\s{0,}\:/{ s/\:.*/\: true/; }' /etc/cloud/cloud.cfg

echo
echo "Host name has been set."
