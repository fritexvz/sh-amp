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

apt -y install vsftpd

# Start the package and set it to start on boot.
pkgOnBoot "vsftpd"

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
