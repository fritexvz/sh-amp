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

echo
echo "Set the host name."

# Create a backup file.
cp -v /etc/hosts{,.bak}
cp -v /etc/cloud/cloud.cfg{,.bak}

# Set the host name
HOST_NAME=""
while [ -z "${HOST_NAME}" ]; do
  read -p "hostname or FQDN (ex) example.com : " HOST_NAME
done

if [ hostname != "${HOST_NAME}" ]; then
  hostnamectl set-hostname "${HOST_NAME}"
fi

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

# Add a variable to the env file.
addPkgCnf -rs="\[HOSTS\]" -fs="=" -o="<<HERE
PUBLIC_IP = $(getPubIPs)
<<HERE"

echo
echo "Host name has been set."
