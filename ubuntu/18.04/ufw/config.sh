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

# Set a relative path.
FILENAME="$(basename $0)"
PKGPATH="$(dirname $0)"
PKGNAME="$(basename "${PKGPATH}")"
OSPATH="$(dirname "${PKGPATH}")"
LIBPATH="${PKGPATH}/lib"
TMPLPATH="${PKGPATH}/tmpl"

# Set absolute path.
ABSROOT="$(cd "$(dirname "")" && pwd)"
ABSENV="${ABSROOT}/env"
ABSOS="${ABSROOT}/${OSPATH}"
ABSPKG="${ABSOS}/${PKGNAME}"
ABSLIB="${ABSPKG}/lib"
ABSTMPL="${ABSPKG}/tmpl"
ABSPATH="${ABSPKG}/${FILENAME}"

# Include the file.
source "${ABSOS}/constants.sh"
source "${ABSOS}/utils.sh"
source "${ABSOS}/functions.sh"

# Make sure the package is installed.
pkgAudit "${PKGNAME}"

echo
echo "Start setting up ${PKGNAME} configuration."

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
echo "${PKGNAME^} configuration is complete."
