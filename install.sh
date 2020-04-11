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

# operating system
echo
echo
echo "On what operating system do you want to install this script?"
echo
while true; do
  read -p "(1) Ubuntu 18.04 (2) Centos 7 : " os
  case $os in
  1)
    OS_ID="ubuntu"
    OS_VERSION_ID="18.04"
    break
    ;;
  2)
    echo "Sorry. Installing the amp does not support centos 7."
    echo
    ;;
  esac
done

# Start Installing
SCRIPTPATH="$OS_ID/$OS_VERSION_ID"

./$SCRIPTPATH/amp.sh
