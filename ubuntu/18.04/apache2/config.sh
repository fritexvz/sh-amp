#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/apache2/config.sh
# ./ubuntu/18.04/apache2/config.sh

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

# Set regex pattern.
SPACE0='[\t ]{0,}'
SPACE1='[\t ]{1,}'

#
# Read the documentation before enabling AddDefaultCharset.
# In general, it is only a good idea if you know that all your files
# have this encoding. It will override any encoding given in the files
# in meta http-equiv or xml encoding tags.

sed -i -E \
  -e "/^[#\t ]{0,}AddDefaultCharset${SPACE1}/{ s/^[#\t ]{1,}//; }" \
  /etc/apache2/conf-available/charset.conf

#
# Disable access to the entire file system except for the directories that
# are explicitly allowed later.

if [ -z "$(cat /etc/apache2/conf-available/security.conf | sed -E -n "/^[#\t ]{0,}ServerTokens${SPACE1}Prod/p")" ]; then
  sed -i -E \
    -e "/^[#\t ]{0,}ServerTokens${SPACE1}Full/a\ServerTokens Prod" \
    /etc/apache2/conf-available/security.conf
fi

sed -i -E \
  -e "/^[#\t ]{0,}<Directory${SPACE1}\/>/,/^[#\t ]{0,}<\/Directory>/{ s/^[#]{1,}//; }" \
  -e "/^[#\t ]{0,}ServerTokens${SPACE1}OS/{ s/^/#/; s/^[#\t ]{1,}/#/; }" \
  -e "/^[#\t ]{0,}ServerTokens${SPACE1}Full/{ s/^/#/; s/^[#\t ]{1,}/#/; }" \
  -e "/^[#\t ]{0,}ServerTokens${SPACE1}Prod/{ s/^[#\t ]{1,}//; }" \
  -e "/^[#\t ]{0,}ServerSignature${SPACE1}On/{ s/^/#/; s/^[#\t ]{1,}/#/; }" \
  -e "/^[#\t ]{0,}ServerSignature${SPACE1}Off/{ s/^[#\t ]{1,}//; }" \
  -e "/^[#\t ]{0,}Header${SPACE1}set${SPACE1}X-Content-Type-Options\s{0,}\:/{ s/^[#\t ]{1,}//; }" \
  -e "/^[#\t ]{0,}Header${SPACE1}set${SPACE1}X-Frame-Options\s{0,}\:/{ s/^[#\t ]{1,}//; }" \
  /etc/apache2/conf-available/security.conf

#
# This is the main Apache server configuration file.  It contains the
# configuration directives that give the server its instructions.
# See http://httpd.apache.org/docs/2.4/ for detailed information about
# the directives and /usr/share/doc/apache2/README.Debian about Debian specific
# hints.

if [ -z "$(cat /etc/apache2/apache2.conf | grep 'This is a configuration dynamically generated by Amp Stack.')" ]; then

  sed -i -E \
    -e '/# vim:(.*)noet/d' \
    /etc/apache2/apache2.conf

  cat >>/etc/apache2/apache2.conf <<APACHE2SCRIPT
$(cat "${ABSPKG}/tmpl/apache2.conf")
APACHE2SCRIPT

fi

#
# prefork MPM
# StartServers: number of server processes to start
# MinSpareServers: minimum number of server processes which are kept spare
# MaxSpareServers: maximum number of server processes which are kept spare
# MaxRequestWorkers: maximum number of server processes allowed to start
# MaxConnectionsPerChild: maximum number of requests a server process serves

STARTSERVERS=10
MAXREQUESTWORKERS=300
MAXCONNECTIONSPERCHILD=0
MINSPARESERVERS=${STARTSERVERS}
MAXSPARESERVERS=$((${MINSPARESERVERS} * 2))
SERVERLIMIT=${MAXREQUESTWORKERS}

echo
echo "Would you like to install mpm_prefork with the following settings?"
echo "STARTSERVERS: ${STARTSERVERS}"
echo "MINSPARESERVERS: ${MINSPARESERVERS}"
echo "MAXSPARESERVERS: ${MAXSPARESERVERS}"
echo "MAXREQUESTWORKERS: ${MAXREQUESTWORKERS}"
echo "SERVERLIMIT: ${SERVERLIMIT}"
echo "MAXCONNECTIONSPERCHILD: ${MAXCONNECTIONSPERCHILD}"

CHANGE_MESSAGE="$(msg -yn "Do you want to change it? (y/n) ")"

if [ "${CHANGE_MESSAGE}" == "Yes" ]; then
  NEW_CONFIG=""
  while [ -z "${NEW_CONFIG}" ]; do
    read -p "STARTSERVERS: " NEW_STARTSERVERS
    read -p "MAXREQUESTWORKERS: " NEW_MAXREQUESTWORKERS
    read -p "MAXCONNECTIONSPERCHILD: " NEW_MAXCONNECTIONSPERCHILD
    read -p "MINSPARESERVERS: " NEW_MINSPARESERVERS
    read -p "MAXSPARESERVERS: " NEW_MAXSPARESERVERS
    read -p "SERVERLIMIT: " NEW_SERVERLIMIT
    SAVE_MESSAGE="$(msg -ync "Do you want to save it? (y/n/c) ")"
    case "${SAVE_MESSAGE}" in
    "Yes")
      STARTSERVERS="${NEW_STARTSERVERS}"
      MAXREQUESTWORKERS="${NEW_MAXREQUESTWORKERS}"
      MAXCONNECTIONSPERCHILD="${NEW_MAXCONNECTIONSPERCHILD}"
      MINSPARESERVERS="${NEW_MINSPARESERVERS}"
      MAXSPARESERVERS="${NEW_MAXSPARESERVERS}"
      SERVERLIMIT="${NEW_SERVERLIMIT}"
      NEW_CONFIG="Yes"
      break
      ;;
    "No")
      NEW_CONFIG=""
      ;;
    "Cancel")
      NEW_CONFIG=""
      break
      ;;
    esac
  done
fi

if [ -z "$(cat /etc/apache2/mods-available/mpm_prefork.conf | sed -E -n "/<IfModule mpm_prefork_module>/,/<\/IfModule>/{ /^${SPACE0}ServerLimit${SPACE1}/p }")" ]; then
  sed -i -E \
    -e "/<IfModule mpm_prefork_module>/,/<\/IfModule>/{ 
        s/^(${SPACE0})(MaxRequestWorkers${SPACE1}.*)/\1\2\n\1Temp_\2/;
        s/Temp_MaxRequestWorkers/ServerLimit/;
      }" \
    /etc/apache2/mods-available/mpm_prefork.conf
fi

sed -i -E \
  -e "/<IfModule mpm_prefork_module>/,/<\/IfModule>/{ 
      s/^(${SPACE0}StartServers${SPACE1}).*/\1${STARTSERVERS}/;
      s/^(${SPACE0}MinSpareServers${SPACE1}).*/\1${MINSPARESERVERS}/;
      s/^(${SPACE0}MaxSpareServers${SPACE1}).*/\1${MAXSPARESERVERS}/;
      s/^(${SPACE0}MaxRequestWorkers${SPACE1}).*/\1${MAXREQUESTWORKERS}/;
      s/^(${SPACE0}ServerLimit${SPACE1}).*/\1${SERVERLIMIT}/;
      s/^(${SPACE0}MaxConnectionsPerChild${SPACE1}).*/\1${MAXCONNECTIONSPERCHILD}/;
    }" \
  /etc/apache2/mods-available/mpm_prefork.conf

# Import variables from the env file.
SITES=("000-default")
PROTO="$(getPkgCnf -rs="\[HOSTS\]" -fs="=" -s="PROTO")"

if [ "${PROTO^^}" == "HTTPS" ]; then
  SITES+=("000-default-ssl")
fi

# Activate the default virtual host.
for ((i = 0; i < ${#SITES[@]}; i++)); do

  # The default server name has been changed to localhost.
  if [ -z "$(cat "/etc/apache2/sites-available/${SITES[$i]}.conf" | sed -E -n "/^${SPACE0}ServerName${SPACE1}/p")" ]; then
    sed -i -E \
      -e "s/^(${SPACE0})(ServerAdmin${SPACE1})(.*)/\1ServerName localhost\n\1\2\3/" \
      "/etc/apache2/sites-available/${SITES[$i]}.conf"
  else
    sed -i -E \
      -e "s/^(${SPACE0}ServerName${SPACE1}).*/\1localhost/" \
      "/etc/apache2/sites-available/${SITES[$i]}.conf"
  fi

  # Activate if you have a site
  if [ -z "$(a2query -s | awk '{print $1}' | egrep "^${SITES[$i]}$")" ]; then
    cd /etc/apache2/sites-available
    a2ensite "${SITES[$i]}.conf"
  fi

done

# Reloading the service.
systemctl reload apache2

echo
echo "${PKGNAME^} configuration is complete."
