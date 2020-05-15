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
PKGNAME=""

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
    PKGNAME="$(basename "${DIRNAME,,}")"
    ;;
  esac
done

# Include the file.
source "${OS_PATH}/utils.sh"
source "${OS_PATH}/functions.sh"
source "${DIRNAME}/functions.sh"

echo
echo "Start installing ${PKGNAME}."

apt -y install vsftpd

# Restart vsftpd. And when Ubuntu restarts, it runs like this:
systemctl stop vsftpd.service
systemctl start vsftpd.service
systemctl enable vsftpd.service

# Create a blank file.
if [ ! -f /etc/vsftpd.user_list ]; then
  echo "" >/etc/vsftpd.user_list
fi
if [ ! -f /etc/vsftpd.chroot_list ]; then
  echo "" >/etc/vsftpd.chroot_list
fi

# Create a backup file.
cp -v /etc/vsftpd.conf{,.bak}
cp -v /etc/ftpusers{,.bak}
cp -v /etc/vsftpd.user_list{,.bak}
cp -v /etc/vsftpd.chroot_list{,.bak}

# Add a variable to the env file.
addPkgCnf -rs="\[VSFTPD\]" -fs="=" -o="<<HERE
VSFTPD_VERSION = $(getVsftpdVer)
<<HERE"

echo
echo "${PKGNAME^} is completely installed."
