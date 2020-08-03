#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/npm/upgrade.sh
# ./ubuntu/18.04/npm/upgrade.sh

# Work even if somebody does "sh thisscript.sh".
set -e

echo
echo "The node package manager package begins to upgrade."

apt -y install --only-upgrade npm

# Reloading the service.
systemctl reload apache2

echo
echo "The node package manager package has been completely upgraded."
