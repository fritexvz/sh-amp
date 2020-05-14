#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/vhost/config.sh
# ./ubuntu/18.04/vhost/config.sh

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
echo "Start setting up vhost configuration."

VHOST_NAME=""

# Set the arguments.
for arg in "${@}"; do
  case "${arg}" in
  --name=*)
    VHOST_NAME="$(echo "${arg}" | sed -E 's/(--name=)//')"
    ;;
  esac
done

VHOST_DIR="/var/www/${VHOST_NAME}"
VHOST_ROOT_DIR="${VHOST_DIR}/html"
VHOST_LOG_DIR="${VHOST_DIR}/logs"

# Setting up vhosting directory
if [ ! -d "${VHOST_ROOT_DIR}" ]; then
  mkdir -p "${VHOST_ROOT_DIR}"
fi
if [ ! -d "${VHOST_LOG_DIR}" ]; then
  mkdir -p "${VHOST_LOG_DIR}"
fi
chown -R www-data:www-data "${VHOST_DIR}"
chmod -R 775 "${VHOST_DIR}"

# Creating new vhosting files
f1="/etc/apache2/sites-available/000-default.conf"
if [ -f ".${f1}" ]; then
  cp -v ".${f1}" "/etc/apache2/sites-available/${VHOST_NAME}.conf"
  sed -i -E \
    -e "s/VHOST_NAME/${VHOST_NAME}/g" \
    -e "s/VHOST_ROOT_DIR/${VHOST_ROOT_DIR}/g" \
    -e "s/VHOST_LOG_DIR/${VHOST_LOG_DIR}/g" \
    "/etc/apache2/sites-available/${VHOST_NAME}.conf"
else
  cat >"/etc/apache2/sites-available/${VHOST_NAME}.conf" <<VHOSTCONFSCRIPT
<VirtualHost *:80>
        ServerName ${VHOST_NAME}
        ServerAdmin webmaster@${VHOST_NAME}
        
        DocumentRoot ${VHOST_ROOT_DIR}

        <Directory "${VHOST_ROOT_DIR}">
            Options +FollowSymLinks -MultiViews -Indexes
            AllowOverride all
            Require all granted
        </Directory>

        #LogLevel info ssl:warn

        ErrorLog ${VHOST_LOG_DIR}/error.log
        CustomLog ${VHOST_LOG_DIR}/access.log combined

        #Include conf-available/serve-cgi-bin.conf
</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
VHOSTCONFSCRIPT
fi

# Disabling default vhosting
if [ ! -z "$(a2query -s | egrep "000-default\s+")" ]; then
  a2dissite 000-default.conf
fi

# Creating new SSL vhosting files
f2="/etc/apache2/sites-available/000-default-ssl.conf"
if [ -f ".${f2}" ]; then
  cp -v ".${f2}" "/etc/apache2/sites-available/${VHOST_NAME}-ssl.conf"
  sed -i -E \
    -e "s/VHOST_NAME/${VHOST_NAME}/g" \
    -e "s/VHOST_ROOT_DIR/${VHOST_ROOT_DIR}/g" \
    -e "s/VHOST_LOG_DIR/${VHOST_LOG_DIR}/g" \
    "/etc/apache2/sites-available/${VHOST_NAME}-ssl.conf"
else
  cat >"/etc/apache2/sites-available/${VHOST_NAME}-ssl.conf" <<VHOSTCONFSCRIPT
<IfModule mod_ssl.c>
        <VirtualHost _default_:443>
                ServerName ${VHOST_NAME}
                ServerAdmin webmaster@${VHOST_NAME}
                
                DocumentRoot ${VHOST_ROOT_DIR}

                <Directory "${VHOST_ROOT_DIR}">
                    Options +FollowSymLinks -MultiViews -Indexes
                    AllowOverride all
                    Require all granted
                </Directory>

                #LogLevel info ssl:warn

                ErrorLog ${VHOST_LOG_DIR}/error.log
                CustomLog ${VHOST_LOG_DIR}/access.log combined

                #Include conf-available/serve-cgi-bin.conf

                SSLEngine on

                SSLCertificateFile      /etc/ssl/certs/ssl-cert-snakeoil.pem
                SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key

                #SSLCertificateChainFile /etc/apache2/ssl.crt/server-ca.crt

                #SSLCACertificatePath /etc/ssl/certs/
                #SSLCACertificateFile /etc/apache2/ssl.crt/ca-bundle.crt

                #SSLCARevocationPath /etc/apache2/ssl.crl/
                #SSLCARevocationFile /etc/apache2/ssl.crl/ca-bundle.crl

                #SSLVerifyClient require
                #SSLVerifyDepth  10

                #SSLOptions +FakeBasicAuth +ExportCertData +StrictRequire
                <FilesMatch "\.(cgi|shtml|phtml|php)$">
                                SSLOptions +StdEnvVars
                </FilesMatch>
                <Directory /usr/lib/cgi-bin>
                                SSLOptions +StdEnvVars
                </Directory>
        </VirtualHost>
</IfModule>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
VHOSTCONFSCRIPT
fi

# Disabling default SSL vhosting
if [ ! -z "$(a2query -s | egrep "000-default-ssl\s+")" ]; then
  a2dissite 000-default-ssl.conf
fi

# Import variables from the env file.
PUBLIC_IP="$(getPkgCnf -rs="\[HOSTS\]" -fs="=" -s="PUBLIC_IP")"

# Adding virtual host name to the /etc/hosts file.
if [ -z "$(cat "/etc/hosts" | egrep "^${PUBLIC_IP}\s+${VHOST_NAME}$")" ]; then
  sed -i "2 a\\${PUBLIC_IP} ${VHOST_NAME}" /etc/hosts
fi

# Enabling new vhosting
a2ensite "${VHOST_NAME}.conf"

# Reload the service
systemctl reload apache2

echo
echo "Vhost configuration is complete."
