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
OS_NAME=$(cat /etc/os-release | awk -F '=' '/^NAME=/{print $2}' | awk '{print $1}' | tr -d '"')

if [ "${OS_NAME}" == "Ubuntu" ]; then
  OS_ID="ubuntu"
  OS_VERSION_ID="18.04"
  OS_PATH="${OS_ID}/${OS_VERSION_ID}"
  # OS_VERSION_ID=$(cat /etc/os-release | awk -F '=' '/^VERSION_ID/{print $2}' | awk '{print $1}' | tr -d '"')
  # case ${OS_VERSION_ID} in
  # "14.04") sudo apt-get update;;
  # "16.04") sudo apt-get update;;
  # "18.04") sudo apt update;;
  # "20.04") sudo apt update;;
  # esac
elif [ "${OS_NAME}" == "CentOS" ]; then
  echo "Sorry. Amp Stack is not supported on CentOS."
  exit 0
else
  echo "Sorry. Amp Stack is not supported on ${OS_NAME}."
  exit 0
fi

# Get a list of directories.
dirPath="./${OS_PATH}/*/"
dirArgs=()
dirExcl=('etc' 'vhost')

IFS=$'\n'
for i in $(ls -d ${dirPath}); do
  i=${i%%/}
  i="$(basename "$i")"
  in_array=""
  if [ ! -z "${dirExcl}" ]; then
    for ((j=0; j<${#dirExcl[@]}; j++)); do
      if [ "${dirExcl[$j]}" == "$i" ]; then
        in_array="Yes"
      fi
    done
  fi
  if [ -z "${in_array}" ]; then
    dirArgs+=("\"$i\"")
  fi
done

PS3="Select the package to be removed. (1-${#dirArgs[@]}) "
select choice in ${dirArgs[@]} "quit"; do
  case "${choice}" in
  "quit")
    exit 0
    ;;
  *)
    PACKAGE_ID="${choice}"
    break
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
