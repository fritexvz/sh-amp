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
# https://kinsta.com/blog/wp-cli/

# Set constants.
OSPATH="$(dirname "$(dirname $0)")"
PKGPATH="$(dirname $0)"
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

wp core download --allow-root
wp core config --allow-root --dbname="${DB_NAME}" --dbuser="${DB_USER}" --dbpass="${DB_PASS}" --dbhost="${DB_HOST}" --dbprefix="${DB_PREFIX}" --extra-php <<PHP
define( 'WP_DEBUG', true );
define( 'WP_DEBUG_LOG', true );
PHP
wp db create
wp core install --allow-root --url="${PROTO}://${VHOST_NAME}" --title="${SITE_TITLE}" --admin_user="${ADMIN_USER}" --admin_password="${ADMIN_PASSWORD}" --admin_email="${ADMIN_EMAIL}"




wp ssh core update --host=clientA

wp theme install twentyseventeen --activate

wp plugin install advanced-custom-fields jetpack https://d1qas1txbec8n.cloudfront.net/wp-content/uploads/2015/06/23073607/myplugin.zip --activate

# List of Current Plugins with Details
wp plugin list

# Update Plugins
wp plugin update --all
wp plugin update wordpress-seo

# Deactivate Multiple Plugins
wp plugin deactivate wordpress-seo
wp plugin deactivate --all

# Manage Roles And Capabilities
wp role create organizer Organizer
wp cap list 'editor' | xargs wp cap add 'organizer'
wp cap add 'organizer' 'manage-events'

# Generate Test Data
wp user generate --count=5 --role=editor
wp user generate --count=10 --role=author
wp term generate --count=12
wp post generate --count=50

# Delete WordPress Revisions
wp post delete $(wp post list --post_type='revision' --format=ids)

# Manage WP-Cron Events
wp cron event list

# Delete Transients
wp transient delete --all
wp transient delete --all --network && wp site list --field=url | xargs -n1 -I % wp --url=% transient delete --all

# Change WordPress URL
wp option update home 'http://example.com'
wp option update siteurl 'http://example.com'

# wp db <command>
wp db size --tables
wp db optimize
wp db repair

# Import And Export
wp db export
wp db import <file>

# Database Search And Replace
wp search-replace oldstring newstring

# Indexing Data with Elasticsearch
wp elasticpress index [--setup] [--network-wide] [--posts-per-page] [--nobulk] [--offset] [--show-bulk-errors] [--post-type]

# Control Maintenance Mode
wp maintenance-mode activate
wp maintenance-mode deactivate
wp maintenance-mode status

echo
echo "${PKGNAME^^} is completely installed."
