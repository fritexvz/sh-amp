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
echo "Start installing mariadb."

apt -y install mariadb-server mariadb-client

# Enables you to improve the security of your MariaDB installation.
/usr/bin/mysql_secure_installation

if [ ! -f /etc/my.cnf ]; then
  echo "" >/etc/my.cnf
fi

# Restart the service.
if [ ! -z "$(isApache2)" ]; then
  systemctl restart apache2
fi

# Add a variable to the env file.
addPkgCnf -rs="\[MARIADB\]" -fs="=" -o="<<HERE
APACHE2_VERSION = $(getMariadbVer)
<<HERE"

# Create a backup file.
cp -v /etc/mysql/mariadb.conf.d/50-server.cnf{,.bak}
cp -v /etc/my.cnf{,.bak}

echo
echo "Mariadb is completely installed."
