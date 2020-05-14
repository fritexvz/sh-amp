#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/vsftpd/install.sh
# ./ubuntu/18.04/vsftpd/install.sh

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
echo "Start installing vsftpd."

apt -y install vsftpd

# Restart vsftpd. And when Ubuntu restarts, it runs like this:
systemctl stop vsftpd.service
systemctl start vsftpd.service
systemctl enable vsftpd.service

# Add a variable to the env file.
addPkgCnf -rs="\[VSFTPD\]" -fs="=" -o="<<HERE
VSFTPD_VERSION = $(getVsftpdVer)
<<HERE"

# Create a backup file.
cp -v /etc/vsftpd.conf{,.bak}
cp -v /etc/ftpusers{,.bak}

f1="/etc/vsftpd.user_list"
if [ ! -f "${f1}" ]; then
  echo "" >"${f1}"
fi
cp -v "${f1}"{,.bak}

f2="/etc/vsftpd.chroot_list"
if [ ! -f "${f2}" ]; then
  echo "" >"${f2}"
fi
cp -v "${f2}"{,.bak}



echo
echo "Vsftpd is completely installed."
