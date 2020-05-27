#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/host/install.sh
# ./ubuntu/18.04/host/install.sh

# Work even if somebody does "sh thisscript.sh".
set -e

# Set constants.
OSPATH="$(dirname "$(dirname $0)")"
PKGPATH="$(dirname $0)"
PKGNAME="$(basename "$(dirname $0)")"
FILENAME="$(basename $0)"

# Set directory path.
ABSROOT="$(cd "$(dirname "")" && pwd)"
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

# Create backup and configuration files.
addPkgCnf "/etc/hosts"
addPkgCnf "/etc/cloud/cloud.cfg"

# Add a variable to the env file.
setPkgCnf -rs="\[HOSTS\]" -fs="=" -o="<<HERE
PUBLIC_IP = $(getPubIPs)
<<HERE"

echo
echo "Host name has been set."
