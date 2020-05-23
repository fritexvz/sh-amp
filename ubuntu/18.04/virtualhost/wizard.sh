#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/virtualhost/wizard.sh
# ./ubuntu/18.04/virtualhost/wizard.sh

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

# Make sure the package is installed.
pkgAudit "apache2"

echo
echo "Start the ${PKGNAME} wizard."

# Set regex pattern.
SPACE0='[\t ]{0,}'
SPACE1='[\t ]{1,}'

# Run the command wizard.
COMMANDS=(
  "List of active virtual hosts."
  "Create a database?"
  "Are you sure you want to delete the database?"
  "Are you sure you want to delete the server?"
  "quit"
)

echo
IFS=$'\n'
PS3="Please select one of the options. (1-${#COMMANDS[@]}): "
select COMMAND in ${COMMANDS[@]}; do
  case "${COMMAND}" in
  "${COMMANDS[0]}")
    a2query -s
    ;;
  "${COMMANDS[1]}")

    echo
    DB_NAME=""
    while [ -z "${DB_NAME}" ]; do
      DB_NAME="$(msg -yn -c "Enter the database name: ")"
      if [ ! -z "$(mysql -uroot -e 'SHOW DATABASES;' | egrep "^${DB_NAME}$")" ] ||
        [ ! -z "$(mysql -uroot -e 'SELECT User FROM mysql.user;' | egrep "^${DB_NAME}$")" ]; then
        echo "${DB_NAME} already exists."
        DB_NAME=""
      fi
    done

    DB_NAME="${DB_NAME//[^a-zA-Z0-9_]/}"
    DB_NAME="${DB_NAME:0:16}"
    DB_USER="${DB_NAME}"
    DB_PASSWORD="$(openssl rand -base64 12)"
    DB_PASSWORD="${DB_PASSWORD:0:16}"

    # Creating a database
    create_database "${DB_NAME}" "${DB_USER}" "${DB_PASSWORD}"

    ;;
  "${COMMANDS[2]}")

    echo
    DB_NAME=""
    while [ -z "${DB_NAME}" ]; do
      DB_NAME="$(msg -yn -c "Enter the database name: ")"
      if [ -z "$(mysql -uroot -e 'SHOW DATABASES;' | egrep "^${DB_NAME}$")" ] ||
        [ -z "$(mysql -uroot -e 'SELECT User FROM mysql.user;' | egrep "^${DB_NAME}$")" ]; then
        echo "${DB_NAME} does not exists."
        DB_NAME=""
      fi
    done
    DB_USER="${DB_NAME}"

    # Deleting a database
    delete_database "${DB_NAME}" "${DB_USER}"

    ;;
  "${COMMANDS[3]}")

    echo
    VHOST_NAME=""
    while [ -z "${VHOST_NAME}" ]; do
      VHOST_NAME="$(msg -yn -c "Enter the domain name. (ex) example.com : ")"
      if [ ! -d "/var/www/${VHOST_NAME}" ]; then
        echo "${VHOST_NAME} does not exists."
        VHOST_NAME=""
      fi
    done

    # Disabling virtualhost
    if [ ! -z "$(a2query -s | awk '{print $1}' | egrep "^${VHOST_NAME}$")" ]; then
      cd /etc/apache2/sites-available
      a2dissite "${VHOST_NAME}.conf"
    fi

    # Disabling SSL virtualhost
    if [ ! -z "$(a2query -s | awk '{print $1}' | egrep "^${VHOST_NAME}-ssl$")" ]; then
      cd /etc/apache2/sites-available
      a2dissite "${VHOST_NAME}-ssl.conf"
    fi

    # Import variables from the env file.
    PUBLIC_IP="$(getPkgCnf -rs="\[HOSTS\]" -fs="=" -s="PUBLIC_IP")"

    # Removing public ip address to the /etc/hosts file
    if [ ! -z "$(cat "/etc/hosts" | egrep "^${PUBLIC_IP}${SPACE1}${VHOST_NAME}$")" ]; then
      sed -i -E "/^${PUBLIC_IP}${SPACE1}${VHOST_NAME}$/d" /etc/hosts
    fi

    # Removing virtualhost directory
    if [ -d "/var/www/${VHOST_NAME}" ]; then
      rm -rf "/var/www/${VHOST_NAME}"
    fi

    # Reloading apache2
    systemctl reload apache2

    ;;
  "${COMMANDS[4]}")
    exit 0
    ;;
  esac
done

echo
echo "Exit the ${PKGNAME} wizard."
