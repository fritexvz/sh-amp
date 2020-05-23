#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./uninstall.sh
# ./uninstall.sh

# Work even if somebody does "sh thisscript.sh".
set -e

# Check to see if script is being run as root
if [ "$(whoami)" != 'root' ]; then
  echo "You have no permission to run $0 as non-root user. Use sudo"
  exit 0
fi

# Check if git is installed
if ! hash git 2>/dev/null; then
  echo -e "Git is not installed! You will need it at some point anyways..."
  echo -e "Exiting, install git first."
  exit 0
fi

#
# lsb_release command is only work for Ubuntu platform but not in centos
# so you can get details from /etc/os-release file
# following command will give you the both OS name and version-
#
# https://askubuntu.com/questions/459402/how-to-know-if-the-running-platform-is-ubuntu-or-centos-with-help-of-a-bash-scri
OS_NAME="$(cat /etc/os-release | awk -F '=' '/^NAME=/{print $2}' | awk '{print $1}' | tr -d '"')"

if [ "${OS_NAME}" == "Ubuntu" ]; then
  OS_ID="ubuntu"
  OS_VERSION_ID="$(cat /etc/os-release | awk -F '=' '/^VERSION_ID=/{print $2}' | awk '{print $1}' | tr -d '"')"
  OS_VERSION_NUMBER="${OS_VERSION_ID//./}"
  if [ "${OS_VERSION_NUMBER}" -lt "1804" ]; then
    echo "Sorry. Amp Stack is not supported on Ubuntu versions below 18.04."
    exit 0
  fi
elif [ "${OS_NAME}" == "CentOS" ]; then
  echo "Sorry. Amp Stack is not supported on CentOS."
  exit 0
else
  echo "Sorry. Amp Stack is not supported on ${OS_NAME}."
  exit 0
fi

# Set up a package list.
PACKAGES=(
  "apache2"
  "fail2ban"
  "mariadb"
  "php"
  "sendmail"
  "ufw"
  "vsftpd"
  "quit"
)

echo
IFS=$'\n'
PS3="Please select one of the options. (1-${#PACKAGES[@]}): "
select PACKAGE in ${PACKAGES[@]}; do
  case "${PACKAGE}" in
  "${PACKAGES[0]}")
    PACKAGE_ID="${PACKAGES[0]}"
    break
    ;;
  "${PACKAGES[1]}")
    PACKAGE_ID="${PACKAGES[1]}"
    break
    ;;
  "${PACKAGES[2]}")
    PACKAGE_ID="${PACKAGES[2]}"
    break
    ;;
  "${PACKAGES[3]}")
    PACKAGE_ID="${PACKAGES[3]}"
    break
    ;;
  "${PACKAGES[4]}")
    PACKAGE_ID="${PACKAGES[4]}"
    break
    ;;
  "${PACKAGES[5]}")
    PACKAGE_ID="${PACKAGES[5]}"
    break
    ;;
  "${PACKAGES[6]}")
    PACKAGE_ID="${PACKAGES[6]}"
    break
    ;;
  "${PACKAGES[7]}")
    exit 0
    ;;
  esac
done

# Run the command wizard.
FILENAME="$(basename $0)"
FILEPATH="/${OS_PATH}/${PACKAGE_ID}/${FILENAME}"
if [ -f ".${FILEPATH}" ]; then
  bash ".${FILEPATH}" --ENVPATH="$(cd "$(dirname "")" && pwd)/env" --ABSPATH="$(cd "$(dirname "")" && pwd)${FILEPATH}"
else
  echo "There is no ${PACKAGE_ID} ${FILENAME%%.*} file."
fi
