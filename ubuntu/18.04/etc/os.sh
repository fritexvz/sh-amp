#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/etc/os.sh
# ./ubuntu/18.04/etc/os.sh

# Work even if somebody does "sh thisscript.sh".
set -e

echo
echo "Upgrade your operating system to the latest."

# Upgrade your operating system to the latest.
apt update && apt -y upgrade

# Installing prerequisites
apt -y install git curl wget zip unzip vim

# Removing unused dependencies
apt -y autoremove

# Setting up Timezone
dpkg-reconfigure tzdata

echo
echo "The operating system has been upgraded to the latest."
