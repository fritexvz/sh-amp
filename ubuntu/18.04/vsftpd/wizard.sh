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
pkgAudit "vsftpd"

# Run the command wizard.
FAQS=(
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
PS3="Choose the next step. (1-${#FAQS[@]}): "
select FAQ in ${FAQS[@]}; do
  case "${FAQ}" in
  "${FAQS[0]}")
    step="createUserAccount"
    break
    ;;
  "${FAQS[1]}")
    step="allowUserRootAccess"
    break
    ;;
  "${FAQS[2]}")
    step="changeUserPassword"
    break
    ;;
  "${FAQS[3]}")
    step="changeUserHomeDirectory"
    break
    ;;
  "${FAQS[4]}")
    step="deleteUserAccount"
    break
    ;;
  "${FAQS[5]}")
    step="allowRootAccount"
    break
    ;;
  "${FAQS[6]}")
    step="denyRootAccount"
    break
    ;;
  "${FAQS[7]}")
    exit 0
    ;;
  esac
done

if [ "${step}" != "allowRootAccount" ] || [ "${step}" != "denyRootAccount" ]; then
  username=""
  while [ -z "${username}" ]; do
    read -p "username: " username
  done
fi

if [ "${step}" == "createUserAccount" ]; then
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
  echo "New users have been added."
fi

if [ "${step}" == "allowUserRootAccess" ]; then
  username_exists "${username}"
  if [ -z "$(cat "/etc/vsftpd.chroot_list" | egrep "^${exists_username}$")" ]; then
    echo "${exists_username}" | tee -a /etc/vsftpd.chroot_list
  else
    echo "${exists_username} is already in chroot_list."
  fi
  echo "User root access is allowed."
fi

if [ "${step}" == "changeUserPassword" ]; then
  username_exists "${username}"
  passwd "${exists_username}"
  echo "User password has been changed."
fi

if [ "${step}" == "changeUserHomeDirectory" ]; then
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
  echo "The user home directory has been changed."
fi

if [ "${step}" == "deleteUserAccount" ]; then
  username_exists "${username}"
  deluser --remove-home "${exists_username}"
  if [ ! -z "$(cat "/etc/vsftpd.user_list" | egrep "^${exists_username}$")" ]; then
    sed -i -E "/^${exists_username}$/d" /etc/vsftpd.user_list
  fi
  if [ ! -z "$(cat "/etc/vsftpd.chroot_list" | egrep "^${exists_username}$")" ]; then
    sed -i -E "/^${exists_username}$/d" /etc/vsftpd.chroot_list
  fi
  echo "The existing user has been deleted."
fi

if [ "${step}" == "allowRootAccount" ]; then
  if [ ! -z "$(cat "/etc/ftpusers" | egrep "^root$")" ]; then
    sed -i -E "/^root$/d" /etc/ftpusers
  fi
  echo "Access to the root account is allowed."
fi

if [ "${step}" == "denyRootAccount" ]; then
  if [ -z "$(cat "/etc/ftpusers" | egrep "^root$")" ]; then
    echo "root" | sudo tee -a /etc/ftpusers
  fi
  echo "Access to the root account is denied."
fi

# Restart the service.
systemctl restart vsftpd
