#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./install.sh
# ./install.sh

# Check to see if script is being run as root
if [ "$(whoami)" != 'root' ]; then
  echo "You have no permission to run $0 as non-root user. Use sudo"
  exit
fi

set -e # Work even if somebody does "sh thisscript.sh".

# Recursive chmod to make all .sh files in the directory executable.
find ./ -type f -name "*.sh" -exec chmod +x {} +

#
# lsb_release command is only work for Ubuntu platform but not in centos 
# so you can get details from /etc/os-release file
# following command will give you the both OS name and version-
#
# https://askubuntu.com/questions/459402/how-to-know-if-the-running-platform-is-ubuntu-or-centos-with-help-of-a-bash-scri
os_name=$(cat /etc/os-release | awk -F '=' '/^NAME/{print $2}' | awk '{print $1}' | tr -d '"')

if [ "$os_name" == "Ubuntu" ]; then
  OS_ID="ubuntu"
  OS_VERSION_ID="18.04"
  # os_version=$(cat /etc/os-release | awk -F '=' '/^VERSION_ID/{print $2}' | awk '{print $1}' | tr -d '"')
  # case $os_version in
  # "14.04")
  #   echo "os version is 14.04"
  #   sudo apt-get update
  #   ;;
  # "16.04")
  #   echo "os version is 16.04"
  #   sudo apt-get update
  #   ;;
  # "18.04")
  #   echo "os version is 18.04"
  #   sudo apt update
  # esac
elif [ "$os_name" == "CentOS" ]; then
  #echo "system is centos"
  #sudo yum update
  echo "Sorry. amp is not supported on $os_name."
else
  #echo "system is $os_name"
  echo "Sorry. amp is not supported on $os_name."
fi

DIR="$OS_ID/$OS_VERSION_ID"

./$DIR/amp.sh

while true; do
  echo 
  echo 
  read -p "Would you like to install the configuration? (y/n)? " answer
  case $answer in
  y | Y)
    ./$DIR/amp-cnf.sh
    break
    ;;
  n | N)
    break
    ;;
  esac
done
