#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/npm/install.sh
# ./ubuntu/18.04/npm/install.sh

# Work even if somebody does "sh thisscript.sh".
set -e

echo
echo "Start installing node package manager."

apt -y install npm

# Reloading the service.
systemctl reload apache2

echo
echo "Node package manager is completely installed."

