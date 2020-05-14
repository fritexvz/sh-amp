#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/ufw/config.sh
# ./ubuntu/18.04/ufw/config.sh

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

# Make sure the package is installed.
pkgAudit "ufw"

echo
echo "Start setting up ufw configuration."

# Allow access to Apache on both port 80 and 443
ufw allow in "Apache Full"

# open ssh port 22
ufw allow OpenSSH

# open ftp: data and command port
ufw allow 20:21/tcp

# open ftp: require implicit FTP over TLS port
ufw allow 990/tcp

# open ftp: passive ports range port
ufw allow 12000:12100/tcp

# open db: mysql
ufw allow 3306/tcp

# open php: memcached
ufw allow 11211/tcp

# open php: redis
ufw allow 6379/tcp

# open php: elasticsearch
ufw allow 9200/tcp

# open mail: smtp
ufw allow 25/tcp
ufw allow 465/tcp
ufw allow 587/tcp
ufw allow 2525/tcp

# open mail: pop3
ufw allow 110/tcp
ufw allow 995/tcp

# open mail: imap
ufw allow 143/tcp
ufw allow 993/tcp

# Restart the package.
ufw disable
ufw enable

echo
echo "Ufw configuration is complete."
