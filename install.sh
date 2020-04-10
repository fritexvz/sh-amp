#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./update.sh
# ./update.sh

# check to see if script is being run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

set -e # Work even if somebody does "sh thisscript.sh".

# Recursive chmod to make all .sh files in the directory executable.
find ./ -type f -name "*.sh" -exec chmod +x {} +

# operating system
while true; do
  printf "\nSelecting operating system. \n"
  select os in "Ubuntu 18.04"; do
    case $os in
    "Ubuntu 18.04")
      OS_PRETTY_NAME="Ubuntu 18.04"
      OS_ID="ubuntu"
      OS_VERSION_ID="18.04"
      break 2
      ;;
    *)
      OS_PRETTY_NAME="Ubuntu 18.04"
      OS_ID="ubuntu"
      OS_VERSION_ID="18.04"
      break 2
      ;;
    esac
  done
done

# Start Installing
SCRIPTPATH="$OS_ID/$OS_VERSION_ID"

./$SCRIPTPATH/install.sh