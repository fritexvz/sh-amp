#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./virtualhost.sh
# ./virtualhost.sh

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
  else
    OS_VERSION_ID="18.04"
  fi
elif [ "${OS_NAME}" == "CentOS" ]; then
  echo "Sorry. Amp Stack is not supported on CentOS."
  exit 0
else
  echo "Sorry. Amp Stack is not supported on ${OS_NAME}."
  exit 0
fi

FILENAME=""
PACKAGE_ID="virtualhost"

# Set the arguments of the file.
for arg in "${@}"; do
  case "${arg}" in
  --*)
    FILENAME="${arg//--/}.sh"
    ;;
  esac
done

# Run the command wizard.
if [ -z "${FILENAME}" ]; then
  COMMANDS=(
    "install"
    "uninstall"
    "wizard"
    "quit"
  )
  echo
  IFS=$'\n'
  PS3="Please select one of the options. (1-${#COMMANDS[@]}): "
  select COMMAND in ${COMMANDS[@]}; do
    case "${COMMAND}" in
    "${COMMANDS[0]}")
      FILENAME="${COMMANDS[0]}.sh"
      break
      ;;
    "${COMMANDS[1]}")
      FILENAME="${COMMANDS[1]}.sh"
      break
      ;;
    "${COMMANDS[2]}")
      FILENAME="${COMMANDS[2]}.sh"
      break
      ;;
    "${COMMANDS[3]}")
      exit 0
      ;;
    esac
  done
fi

# Set up a package list.
FILEPATH="${OS_ID}/${OS_VERSION_ID}/${PACKAGE_ID}/${FILENAME}"
if [ -f "${FILEPATH}" ]; then
  bash "${FILEPATH}"
else
  echo "There is no ${PACKAGE_ID} ${FILENAME%%.*} file."
fi
