#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/wp-cli/install.sh
# ./ubuntu/18.04/wp-cli/install.sh
#
# Installation
# https://github.com/wp-cli/wp-cli
# https://make.wordpress.org/cli/handbook/quick-start/

# Work even if somebody does "sh thisscript.sh".
set -e

# Set constants.
OSPATH="$(dirname "$(dirname $0)")"
PKGNAME="$(basename "$(dirname $0)")"
FILENAME="$(basename $0)"

# Set directory path.
ABSROOT="${1#*=}"
ABSENV="${ABSROOT}/env"
ABSOS="${ABSROOT}/${OSPATH}"
ABSPKG="${ABSOS}/${PKGNAME}"
ABSPATH="${ABSPKG}/${FILENAME}"

# Include the file.
source "${ABSOS}/utils.sh"
source "${ABSOS}/functions.sh"
source "${ABSPKG}/functions.sh"

echo
echo "Start installing ${PKGNAME^^}."

# Once you've verified requirements, download the wp-cli.phar file using wget or curl:
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

# Next, check the Phar file to verify that it's working:
php wp-cli.phar --info

# To use WP-CLI from the command line by typing wp, make the file executable and move it to somewhere in your PATH. For example:
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

# If WP-CLI was installed successfully, you should see something like this when you run wp --info:
wp --info

echo
echo "${PKGNAME^^} is completely installed."
