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

# Set constants in the file.
ENVPATH=""
ABSPATH=""
OS_PATH=""

# Set the arguments of the file.
for arg in "${@}"; do
  case "${arg}" in
  --ENVPATH=*)
    ENVPATH="$(echo "${arg}" | sed -E 's/(--ENVPATH=)//')"
    ;;
  --ABSPATH=*)
    ABSPATH="$(echo "${arg}" | sed -E 's/(--ABSPATH=)//')"
    OS_PATH="$(dirname "$(dirname "${ABSPATH}")")"
    ;;
  esac
done

# Include the file.
source "${OS_PATH}/utils.sh"
source "${OS_PATH}/functions.sh"
source "functions.sh"

echo
echo "Set the host name."

# Set the host name
HOST_NAME=""
while [ -z "${HOST_NAME}" ]; do
  read -p "hostname or FQDN (ex) example.com : " HOST_NAME
done

if [ hostname != "${HOST_NAME}" ]; then
  hostnamectl set-hostname "${HOST_NAME}"
fi

# hosts
f1="/etc/hosts"
if [ -f ".${f1}" ]; then
  cp -v "${f1}"{,.bak}
  cp ".${f1}" "${f1}"
else
  cp -v "${f1}"{,.bak}
  if [ -z "$(cat "${f1}" | grep "127.0.1.1 ${HOST_NAME}")" ]; then
    sed -i -e "1 a\127.0.1.1 ${HOST_NAME}" "${f1}"
  fi
fi

# This will cause the set+update hostname module to not operate (if true)
f2="/etc/cloud/cloud.cfg"
if [ -f ".${f2}" ]; then
  cp -v "${f2}"{,.bak}
  cp ".${f2}" "${f2}"
else
  cp -v "${f2}"{,.bak}
  sed -i -E -e '/preserve_hostname\s{0,}\:/{ s/\:.*/\: true/; }' "${f2}"
fi

# Add a variable to the env file.
addPkgCnf -rs="\[HOSTS\]" -fs="=" -o="<<HERE
PUBLIC_IP = $(getPubIPs)
<<HERE"

echo
echo "Host name has been set."
