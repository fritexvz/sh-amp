#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/mariadb/install.sh
# ./ubuntu/18.04/mariadb/install.sh

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

apt -y install mariadb-server mariadb-client

# Enables you to improve the security of your MariaDB installation.
/usr/bin/mysql_secure_installation

# Start the package and set it to start on boot.
pkgOnBoot "mariadb"

# Reloading the service.
systemctl reload apache2

# Create a blank file.
if [ ! -f /etc/my.cnf ]; then
  echo "" >/etc/my.cnf
fi

# Create a backup file.
cp -v /etc/mysql/mariadb.conf.d/50-server.cnf{,.bak}
cp -v /etc/my.cnf{,.bak}

# Add a variable to the env file.
addPkgCnf -rs="\[MARIADB\]" -fs="=" -o="<<HERE
MARIADB_VERSION = $(getMariadbVer)
<<HERE"

echo
echo "${PKGNAME^} is completely installed."
