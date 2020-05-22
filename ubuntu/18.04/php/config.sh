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

# Set global constants.
ENVPATH=""
ABSPATH=""
DIRNAME=""
OS_PATH=""
PKGNAME=""

# Set regex pattern.
SPACE0='[\t ]{0,}'
SPACE1='[\t ]{1,}'

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

# Make sure the package is installed.
pkgAudit "${PKGNAME}"

# Import variables from the env file.
PHP_VERSION="$(getPkgCnf -rs="\[PHP\]" -fs="=" -s="PHP_VERSION")"

echo
echo "Start setting up ${PKGNAME} configuration."

# Tell the web server to prefer PHP files over others, so make Apache look for an index.php file first.
f_dir="/etc/apache2/mods-available/dir.conf"
if [ -f ".${f_dir}" ]; then
  cp -v ".${f_dir}" "${f_dir}"
else
  sed -i -E \
    -e "/DirectoryIndex\s+/{ 
      s/${SPACE1}index.php//;
      s/index.html/index.php index.html/;
    }" \
    "${f_dir}"
fi

# Deny access to files without filename (e.g. '.php')
f_conf="/etc/apache2/mods-available/php${PHP_VERSION}.conf"

if [ -f ".${f_conf}" ]; then
  cp -v ".${f_conf}" "${f_conf}"
else
  sed -i \
    -e '/<FilesMatch/{
      s/ph(ar|p|tml)/ph(ar|p[3457]?|tml)/;
      s/ph(ar|p|ps|tml)/ph(p[3457]?|t|tml|ps)/;
    }' \
    "${f_conf}"
fi

# php.ini
f_ini="/etc/php/${PHP_VERSION}/apache2/php.ini"

if [ -f ".${f_ini}" ]; then
  cp -v ".${f_ini}" "${f_ini}"
else

  addPkgCnf -f="${f_ini}" -rs="\[PHP\]" -fs="=" -o="<<HERE
$(cat "${DIRNAME}/tmpl/php.ini")
<<HERE"

  addPkgCnf -f="${f_ini}" -rs="\[Date\]" -fs="=" -o="<<HERE
date.timezone = $(cat /etc/timezone)
<<HERE"

fi

# Restart the service.
if [ ! -z "$(isApache2)" ]; then
  systemctl restart apache2
fi

echo
echo "${PKGNAME^^} configuration is complete."
