#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/amp-vhost.sh
# ./ubuntu/18.04/amp-vhost.sh

# Check to see if script is being run as root
if [ "$(whoami)" != 'root' ]; then
  echo "You have no permission to run $0 as non-root user. Use sudo"
  exit
fi

# Check if git is installed
if ! hash git 2>/dev/null; then
  echo -e "Git is not installed! You will need it at some point anyways..."
  echo -e "Exiting, install git first."
  exit 0
fi

set -e # Work even if somebody does "sh thisscript.sh".

printf "\n\nSetting up vhosting ... \n"

# Selecting Step
PS3="Choose the next step. (1-4): "
select choice in "default" "laravel" "wordpress" "quit"; do
  case $choice in
  "default")
    step="default"
    break
    ;;
  "laravel")
    step="laravel"
    break
    ;;
  "wordpress")
    step="wordpress"
    break
    ;;
  "quit")
    exit
    ;;
  esac
done

VHOSTNAME=""
while [[ -z "$VHOSTNAME" ]]; do
  read -p "Enter ServerName without an alias. (ex) example.com : " VHOSTNAME
  if [ -d /var/www/$VHOSTNAME ]; then
    echo $VHOSTNAME " directory is already exists."
    VHOSTNAME=""
  fi
done

printf "\n\nSetting up vhosting directory ... \n"
if [ ! -d /var/www/$VHOSTNAME/html ]; then
  mkdir -p /var/www/$VHOSTNAME/html
fi
chown -R www-data:www-data /var/www/$VHOSTNAME
chmod -R 775 /var/www/$VHOSTNAME

printf "\n\nCreating new vhosting files ... \n"
cp /var/www/html/index.html /var/www/$VHOSTNAME/html/index.html
cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/$VHOSTNAME.conf
cat >/etc/apache2/sites-available/$VHOSTNAME.conf <<EOF
<VirtualHost *:80>
    ServerAdmin sysadmin@_temp
    ServerName _temp
    ServerAlias www._temp
    
    DocumentRoot /var/www/_temp/html

    <Directory "/var/www/_temp/html">
        Options +FollowSymLinks -MultiViews -Indexes
        AllowOverride all
        Require all granted
    </Directory>

    ErrorLog /var/www/_temp/logs/error.log
    CustomLog /var/www/_temp/logs/access.log combined
</VirtualHost>
EOF

if [ $step == "laravel" ]; then
  sed i -E -e "/DocumentRoot/{ s#_temp/html#_temp/html/public#; }"
fi

dots=$(echo "$VHOSTNAME" | tr -cd . | wc -c)
if [ $dots -gt 1 ]; then
  if egrep -q "/ServerAlias\s+www\._temp/" /etc/apache2/sites-available/$VHOSTNAME.conf; then
    sed i -E -e "/ServerAlias\s+www\._temp/d" /etc/apache2/sites-available/$VHOSTNAME.conf
  fi
fi

sed i -E -e "s/_temp/$VHOSTNAME/" /etc/apache2/sites-available/$VHOSTNAME.conf

echo "Adding $VHOSTNAME to the /etc/hosts file ... \n"
PUBLIC_IP="$(curl ifconfig.me)"
if ! grep -q "$PUBLIC_IP $VHOSTNAME" /etc/hosts; then
  sed -i "2 a\\$PUBLIC_IP $VHOSTNAME" /etc/hosts
fi

if egrep -q "000-default" apache2ctl -S; then
  printf "\n\nDiabling default vhosting ... \n"
  a2dissite 000-default.conf
  systemctl reload apache2
  systemctl status apache2
fi

printf "\n\nEnabling new vhosting ... \n"
a2ensite $VHOSTNAME.conf
service apache2 restart
