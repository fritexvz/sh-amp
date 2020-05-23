#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/vsftpd/wizard.sh
# ./ubuntu/18.04/vsftpd/wizard.sh

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
pkgAudit "${PKGNAME}"

echo
echo "Start the ${PKGNAME} wizard."

# Run the command wizard.
COMMANDS=(
  "Create a new ftp user?"
  "Do you want users to access root?"
  "Would you like to change the user password?"
  "Change user's home directory?"
  "Are you sure you want to delete the existing user?"
  "Do you want to allow root account?"
  "Do you want to reject the root account?"
  "quit"
)

echo
IFS=$'\n'
PS3="Please select one of the options. (1-${#COMMANDS[@]}): "
select COMMAND in ${COMMANDS[@]}; do
  case "${COMMAND}" in
  "${COMMANDS[0]}")
    # "Create a new ftp user?"
    username=""
    while [ -z "${username}" ]; do
      read -p "username: " username
    done

    username_create "${username}"
    adduser "${create_username}"
    usermod -a -G www-data "${create_username}"
    if [ -z "$(cat "/etc/vsftpd.user_list" | egrep "^${create_username}$")" ]; then
      echo "${create_username}" | tee -a /etc/vsftpd.user_list
    else
      echo "${create_username} is already in user_list."
    fi

    # Disabling Shell Access
    usermod "${create_username}" -s /bin/ftponly

    # Restart the service.
    systemctl restart vsftpd

    echo "New users have been added."
    ;;
  "${COMMANDS[1]}")
    # "Do you want users to access root?"
    username=""
    while [ -z "${username}" ]; do
      read -p "username: " username
    done

    username_exists "${username}"
    if [ -z "$(cat "/etc/vsftpd.chroot_list" | egrep "^${exists_username}$")" ]; then
      echo "${exists_username}" | tee -a /etc/vsftpd.chroot_list
    else
      echo "${exists_username} is already in chroot_list."
    fi

    # Restart the service.
    systemctl restart vsftpd

    echo "User root access is allowed."
    ;;
  "${COMMANDS[2]}")
    # "Would you like to change the user password?"
    username=""
    while [ -z "${username}" ]; do
      read -p "username: " username
    done

    username_exists "${username}"
    passwd "${exists_username}"

    # Restart the service.
    systemctl restart vsftpd

    echo "User password has been changed."
    ;;
  "${COMMANDS[3]}")
    # "Change user's home directory?"
    username=""
    while [ -z "${username}" ]; do
      read -p "username: " username
    done

    username_exists "${username}"
    userdir=""
    while [ -z "${userdir}" ]; do
      read -p "user's home directory: " userdir
      if [ ! -d "${userdir}" ]; then
        echo "Directory does not exist."
        while true; do
          read -p "Do you want to create a directory? (y/n) " ansusrmod
          case "${ansusrmod}" in
          y | Y)
            mkdir -p "${userdir}"
            break 2
            ;;
          n | N)
            break
            ;;
          esac
        done
      fi
    done
    chown -R www-data:www-data "${userdir}"
    chmod -R 775 "${userdir}"

    # Restart the service.
    systemctl restart vsftpd

    echo "The user home directory has been changed."
    ;;
  "${COMMANDS[4]}")
    # "Are you sure you want to delete the existing user?"
    username=""
    while [ -z "${username}" ]; do
      read -p "username: " username
    done

    username_exists "${username}"
    deluser --remove-home "${exists_username}"
    if [ ! -z "$(cat "/etc/vsftpd.user_list" | egrep "^${exists_username}$")" ]; then
      sed -i -E "/^${exists_username}$/d" /etc/vsftpd.user_list
    fi
    if [ ! -z "$(cat "/etc/vsftpd.chroot_list" | egrep "^${exists_username}$")" ]; then
      sed -i -E "/^${exists_username}$/d" /etc/vsftpd.chroot_list
    fi

    # Restart the service.
    systemctl restart vsftpd

    echo "The existing user has been deleted."
    ;;
  "${COMMANDS[5]}")
    # "Do you want to allow root account?"

    if [ ! -z "$(cat "/etc/ftpusers" | egrep "^root$")" ]; then
      sed -i -E "/^root$/d" /etc/ftpusers
    fi

    # Restart the service.
    systemctl restart vsftpd

    echo "Access to the root account is allowed."
    ;;
  "${COMMANDS[6]}")
    # "Do you want to reject the root account?"

    if [ -z "$(cat "/etc/ftpusers" | egrep "^root$")" ]; then
      echo "root" | sudo tee -a /etc/ftpusers
    fi

    # Restart the service.
    systemctl restart vsftpd
    
    echo "Access to the root account is denied."
    ;;
  "${COMMANDS[7]}")
    # "quit"
    exit 0
    ;;
  esac
done

echo
echo "Exit the ${PKGNAME} wizard."
