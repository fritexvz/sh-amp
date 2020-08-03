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

# Set the arguments.
for arg in "${@}"; do
  case $arg in
  --my)
    IFS=$'\n'
    for i in $(find "${ABSPKG}/etc" -type f -name "[^_]*"); do
      cp "$i" "$(echo "$i" | sed "s/${ABSPKG//\//\\/}//")"
    done
    echo "${PKGNAME^} configuration is complete."
    exit 0
    ;;
  esac
done

# Import variables from the env file.
PHP_VERSION="$(getPkgCnf -rs="\[PHP\]" -fs="=" -s="PHP_VERSION")"

# Set regex pattern.
SPACE0='[\t ]{0,}'
SPACE1='[\t ]{1,}'

# Tell the web server to prefer PHP files over others, so make Apache look for an index.php file first.
sed -i -E \
  -e "/DirectoryIndex\s+/{ 
      s/${SPACE1}index.php//;
      s/index.html/index.php index.html/;
    }" \
  "/etc/apache2/mods-available/dir.conf"

# Deny access to files without filename (e.g. '.php')
sed -i \
  -e '/<FilesMatch/{
      s/ph(ar|p|tml)/ph(ar|p[3457]?|tml)/;
      s/ph(ar|p|ps|tml)/ph(p[3457]?|t|tml|ps)/;
    }' \
  "/etc/apache2/mods-available/php${PHP_VERSION}.conf"

# Edit the string using here document.
setPkgCnf -f="/etc/php/${PHP_VERSION}/apache2/php.ini" -rs="\[PHP\]" -fs="=" -o="<<HERE
$(cat "${ABSTMPL}/php.ini")
<<HERE"

# Edit the string using here document.
setPkgCnf -f="/etc/php/${PHP_VERSION}/apache2/php.ini" -rs="\[Date\]" -fs="=" -o="<<HERE
date.timezone = $(cat /etc/timezone)
<<HERE"

# Restarting the service.
systemctl restart apache2

echo
echo "${PKGNAME^^} configuration is complete."
