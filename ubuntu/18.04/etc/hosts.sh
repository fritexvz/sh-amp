#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/etc/hosts.sh
# ./ubuntu/18.04/etc/hosts.sh

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
echo "Set the host name."

# Import variables from the env file.
PUBLIC_IP="$(getPubIPs)"

# Add a variable to the env file.
addPkgCnf -rs="\[HOSTS\]" -fs="=" -o="<<HERE
PUBLIC_IP = ${PUBLIC_IP}
<<HERE"

# Set the host name
CHANGE_MESSAGE="$(msg -yn "Do you want to change host name? (y/n) ")"
if [ "${CHANGE_MESSAGE}" == "No" ]; then
  exit 0
fi

# Set the host name
HOST_NAME="$(msg -yn -c "hostname or FQDN (ex) example.com : ")"

if [ hostname != "${HOST_NAME}" ]; then
  hostnamectl set-hostname "${HOST_NAME}"
fi

# Create a backup file.
cp -v /etc/hosts{,.bak}
cp -v /etc/cloud/cloud.cfg{,.bak}

f_hosts="/etc/hosts"

if [ -f ".${f_hosts}" ]; then
  cp -v ".${f_hosts}" "${f_hosts}"
else
  if [ -z "$(cat "${f_hosts}" | grep "127.0.1.1 ${HOST_NAME}")" ]; then
    sed -i -e "1 a\127.0.1.1 ${HOST_NAME}" "${f_hosts}"
  fi
fi

# This will cause the set+update hostname module to not operate (if true)
f_cloud="/etc/cloud/cloud.cfg"

if [ -f ".${f_cloud}" ]; then
  cp -v ".${f_cloud}" "${f_cloud}"
else
  sed -i -E -e '/preserve_hostname\s{0,}\:/{ s/\:.*/\: true/; }' "${f_cloud}"
fi

echo
echo "Host name has been set."
