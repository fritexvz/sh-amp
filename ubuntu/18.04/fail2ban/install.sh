#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/fail2ban/install.sh
# ./ubuntu/18.04/fail2ban/install.sh

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

apt -y install fail2ban whois

# Start the package and set it to start on boot.
pkgOnBoot "fail2ban"

# Create a blank file.
if [ ! -f /etc/fail2ban/jail.local ]; then
  echo "" >/etc/fail2ban/jail.local
fi

# Create a backup file.
cp -v /etc/fail2ban/jail.conf{,.bak}
cp -v /etc/fail2ban/jail.local{,.bak}

# Add a variable to the env file.
addPkgCnf -rs="\[FAIL2BAN\]" -fs="=" -o="<<HERE
FAIL2BAN_VERSION = $(getFail2banVer)
<<HERE"

echo
echo "${PKGNAME^} is completely installed."
