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

# Set constants in the file.
ENVPATH=""
ABSPATH=""
OS_PATH=""

# Set the arguments of the file.
for arg in "${@}"; do
  case "${arg}" in
  --ENVPATH=*)
    ENVPATH="$(echo "${arg}" | sed -E 's/(--ENVPATH=)//')"
    ;;
  --ABSPATH=*)
    ABSPATH="$(echo "${arg}" | sed -E 's/(--ABSPATH=)//')"
    OS_PATH="$(dirname "$(dirname "${ABSPATH}")")"
    ;;
  esac
done

# Include the file.
source "${OS_PATH}/utils.sh"
source "${OS_PATH}/functions.sh"
source "functions.sh"

# Make sure the package is installed.
pkgAudit "apache2"

echo
echo "Start setting up apache2 configuration."

f1="/etc/apache2/conf-available/charset.conf"
if [ -f ".${f1}" ]; then
  cp ".${f1}" "${f1}"
else
  sed -i -E \
    -e "/^[# ]{0,}AddDefaultCharset\s{1,}/{ s/^[# ]{1,}//; }" \
    "${f1}"
fi

# This currently breaks the configurations that come with some web application Debian packages.
# Hide server version and virtual host name on the client.
# prevent MSIE from interpreting files as some else.
# This depends against clickjacking attacks.
f2="/etc/apache2/conf-available/security.conf"
if [ -f ".${f2}" ]; then
  cp ".${f2}" "${f2}"
else
  if [ -z "$(cat "${f2}" | egrep '^[# ]{0,}ServerTokens\s+Prod')" ]; then
    sed -i -E \
      -e "/^[# ]{0,}ServerTokens\s+Full/a\ServerTokens Prod" \
      "${f2}"
  fi
  sed -i -E \
    -e "/^[# ]{0,}<Directory\s+\/>/,/^[# ]{0,}<\/Directory>/{ s/^[#]{1,}//; }" \
    -e "/^[# ]{0,}ServerTokens\s+OS/{ s/^/#/; s/^[# ]{1,}/#/; }" \
    -e "/^[# ]{0,}ServerTokens\s+Full/{ s/^/#/; s/^[# ]{1,}/#/; }" \
    -e "/^[# ]{0,}ServerTokens\s+Prod/{ s/^[# ]{1,}//; }" \
    -e "/^[# ]{0,}ServerSignature\s+On/{ s/^/#/; s/^[# ]{1,}/#/; }" \
    -e "/^[# ]{0,}ServerSignature\s+Off/{ s/^[# ]{1,}//; }" \
    -e "/^[# ]{0,}Header\s+set\s+X-Content-Type-Options\s{0,}\:/{ s/^[# ]{1,}//; }" \
    -e "/^[# ]{0,}Header\s+set\s+X-Frame-Options\s{0,}\:/{ s/^[# ]{1,}//; }" \
    "${f2}"
fi

f3="/etc/apache2/apache2.conf"
if [ -f ".${f3}" ]; then
  cp ".${f3}" "${f3}"
else
  if [ -z "$(cat "${f3}" | egrep 'This is a configuration dynamically generated by Amp Stack.')" ]; then
    sed -i -e '$ i\
#\
#\
# This is a configuration dynamically generated by Amp Stack.
# Deny access to file and folder names beginning with dot.\
#<DirectoryMatch "^\.|\/\.">\
#  Require all denied\
#</DirectoryMatch>\
#\
# Deny access to file extensions(log file, binary, certificate, shell script, sql dump file).\
<FilesMatch "\.(?i:log|binary|pem|enc|crt|conf|cnf|sql|sh|key|yml|lock|gitignore)$">\
  Require all denied\
</FilesMatch>\
#\
# Deny access to file names.\
<FilesMatch "(?i:composer\.json|contributing\.md|license\.txt|readme\.rst|readme\.md|readme\.txt|copyright|artisan|gulpfile\.js|package\.json|phpunit\.xml|access_log|error_log|gruntfile\.js|bower\.json|changelog\.md|console|legalnotice|license|security\.md|privacy\.md)$">\
  Require all denied\
</FilesMatch>\
#\
# Allow Lets Encrypt Domain Validation Program.\
<DirectoryMatch "\.well-known/acme-challenge/">\
  Require all granted\
</DirectoryMatch>\
#\
# Block .php file inside upload folder. uploads(wp), files(drupal), data(gnuboard).\
<DirectoryMatch "/(uploads|default/files|data|wp-content/themes)/">\
  <FilesMatch ".+\.php$">\
    Require all denied\
  </FilesMatch>\
</DirectoryMatch>\
# This is the last line of configuration dynamically generated by Amp Stack.
    ' "${f3}"
  fi
fi

# mpm-itk allows you to run each of your vhost under a separate uid and gid—in short,
# the scripts and configuration files for one vhost no longer have to be readable for all the other vhosts.
apt-cache search mpm-itk
apt -y install libapache2-mpm-itk
chmod 711 /home
chmod -R 700 /home/*

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

# mpm_prefork.conf
f4="/etc/apache2/mods-available/mpm_prefork.conf"
if [ -f ".${f4}" ]; then
  cp ".${f4}" "${f4}"
else
  if [ -z "$(cat "${f4}" | egrep '^[# ]{0,}ServerLimit\s+')" ]; then
    sed -i -E \
      -e "/<IfModule mpm_prefork_module>/,/<\/IfModule>/{ 
        /^[# ]{0,}MaxRequestWorkers\s+/a\ServerLimit ${SERVERLIMIT} 
      }" "${f4}"
  fi
  sed -i -E \
    -e "/<IfModule mpm_prefork_module>/,/<\/IfModule>/{ s/^[# ]{0,}(StartServers\s+).*/\1${STARTSERVERS}/; }" \
    -e "/<IfModule mpm_prefork_module>/,/<\/IfModule>/{ s/^[# ]{0,}(MinSpareServers\s+).*/\1${MINSPARESERVERS}/; }" \
    -e "/<IfModule mpm_prefork_module>/,/<\/IfModule>/{ s/^[# ]{0,}(MaxSpareServers\s+).*/\1${MAXSPARESERVERS}/; }" \
    -e "/<IfModule mpm_prefork_module>/,/<\/IfModule>/{ s/^[# ]{0,}(MaxRequestWorkers\s+).*/\1${MAXREQUESTWORKERS}/; }" \
    -e "/<IfModule mpm_prefork_module>/,/<\/IfModule>/{ s/^[# ]{0,}(ServerLimit\s+).*/\1${SERVERLIMIT}/; }" \
    -e "/<IfModule mpm_prefork_module>/,/<\/IfModule>/{ s/^[# ]{0,}(MaxConnectionsPerChild\s+).*/\1${MAXCONNECTIONSPERCHILD}/; }" \
    "${f4}"
fi

SERVERNAME="localhost"

# Site available
f5="/etc/apache2/sites-available/000-default.conf"
if [ -f ".${f5}" ]; then
  cp ".${f5}" "${f5}"
else
  if [ -z "$(cat "${f5}" | egrep '^[# ]{0,}ServerName\s+')" ]; then
    sed -i -E \
      -e "/^[# ]{0,}ServerAdmin\s+/i\ServerName ${SERVERNAME}" \
      "${f5}"
  else
    sed -i -E \
      -e "s/^[# ]{0,}(ServerName)\s+/\1 ${SERVERNAME}/" \
      "${f5}"
  fi
fi

# SSL site available
f6="/etc/apache2/sites-available/000-default-ssl.conf"
if [ -f ".${f6}" ]; then
  cp ".${f6}" "${f6}"
  a2ensite 000-default-ssl.conf
else
  if [ -z "$(cat "${f6}" | egrep '^[# ]{0,}ServerName\s+')" ]; then
    sed -i -E \
      -e "/^[# ]{0,}ServerAdmin\s+/i\ServerName ${SERVERNAME}" \
      "${f6}"
  else
    sed -i -E \
      -e "s/^[# ]{0,}(ServerName)\s+/\1 ${SERVERNAME}/" \
      "${f6}"
  fi
  a2ensite 000-default-ssl.conf
fi

# Reload the service.
systemctl restart apache2

echo
echo "Apache2 configuration is complete."
