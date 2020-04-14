#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./restore.sh
# ./restore.sh

# Check to see if script is being run as root
if [ "$(whoami)" != 'root' ]; then
  echo "You have no permission to run $0 as non-root user. Use sudo"
  exit
fi

set -e # Work even if somebody does "sh thisscript.sh".

# Selecting operating system
echo "On what operating system do you want to install this script?"
PS3="Please select your operating system. (1-2): "
select os in "Ubuntu 18.04" "Centos 7"; do
  case $os in
  "Ubuntu 18.04")
    OS_ID="ubuntu"
    OS_VERSION_ID="18.04"
    break
    ;;
  "Centos 7")
    echo "Sorry. restore of amp is not supported on centos 7."
    ;;
  esac
done

DIR="$OS_ID/$OS_VERSION_ID"

./$DIR/amp-bak.sh
