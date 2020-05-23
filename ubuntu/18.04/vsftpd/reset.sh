#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/vsftpd/reset.sh
# ./ubuntu/18.04/vsftpd/reset.sh

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

# Make sure the package is installed.
pkgAudit "${PKGNAME}"

echo
echo "Reset the ${PKGNAME} configuration."

# Reset the file.
cp -v /etc/vsftpd.conf.bak /etc/vsftpd.conf
cp -v /etc/vsftpd.user_list.bak /etc/vsftpd.user_list
cp -v /etc/vsftpd.chroot_list.bak /etc/vsftpd.chroot_list

# Restart the service.
systemctl restart vsftpd

echo
echo "The ${PKGNAME} configuration has been reset."