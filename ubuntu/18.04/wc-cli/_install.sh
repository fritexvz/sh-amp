#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/wc-cli/install.sh
# ./ubuntu/18.04/wc-cli/install.sh
#
# Installation
# https://robotninja.com/blog/wp-cli-woocommerce-development/

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

# Creating Products
#wp wc product create -–name="Test Product" --type=simple --sku=WCCLITESTP --regular_price=20 –user
wp wc product create -–name="Test Product" --type=simple --sku=WCCLITESTP --regular_price=20 –user --product_url="https://domain.com/product/test/" --button_text="Buy me"

# Creating Bulk Products
wp cyclone products <amount> [--type=<type>]

# Getting a List of Orders
wp wc shop_order list --customer=1 --user=1 --fields=id,status

# Getting a List of Customers
wp wc customer list --user=1 --fields=id,email

# WooCommerce Memberships
#wp wc memberships
#wp wc memberships membership create --customer=1 --plan=100
wp wc memberships membership create --customer=1 --plan="silver" --start_date="2016-01-01" --end_date="2016-06-30" --status="expired"

echo
echo "${PKGNAME^^} is completely installed."
