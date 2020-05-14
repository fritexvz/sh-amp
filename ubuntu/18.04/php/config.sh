#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/php/config.sh
# ./ubuntu/18.04/php/config.sh

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
pkgAudit "php"

# Import variables from the env file.
PHP_VERSION="$(getPkgCnf -rs="\[PHP\]" -fs="=" -s="PHP_VERSION")"

echo
echo "Start setting up php configuration."

# Tell the web server to prefer PHP files over others, so make Apache look for an index.php file first.
f1="/etc/apache2/mods-available/dir.conf"
if [ -f ".${f1}" ]; then
  cp ".${f1}" "${f1}"
else
  sed -i -E \
    -e "/DirectoryIndex/{ s/\s+index.php//; s/index.html/index.php index.html/; }" \
    "${f1}"
fi

# Deny access to files without filename (e.g. '.php')
f2="/etc/apache2/mods-available/php${PHP_VERSION}.conf"
if [ -f ".${f2}" ]; then
  cp ".${f2}" "${f2}"
else
  sed -i \
    -e '/<FilesMatch/{ s/ph(ar|p|tml)/ph(ar|p[3457]?|tml)/; }' \
    -e '/<FilesMatch/{ s/ph(ar|p|ps|tml)/ph(p[3457]?|t|tml|ps)/; }' \
    "${f2}"
fi

# php.ini
f3="/etc/php/${PHP_VERSION}/apache2/php.ini"
if [ -f ".${f3}" ]; then
  cp ".${f3}" "${f3}"
else
  addPkgCnf -f="${f3}" -rs="\[PHP\]" -fs="=" -o="<<HERE
short_open_tag = On
max_execution_time = 3600
max_input_time = 3600
max_input_vars = 10000
memory_limit = 256M
display_errors = On
post_max_size = 1024M
upload_max_filesize = 960M
max_file_uploads = 100
<<HERE"
  addPkgCnf -f="${f3}" -rs="\[Date\]" -fs="=" -o="<<HERE
date.timezone = $(cat /etc/timezone)
<<HERE"
fi

# Restart the service.
if [ ! -z "$(isApache2)" ]; then
  systemctl restart apache2
fi

echo
echo "PHP configuration is complete."
