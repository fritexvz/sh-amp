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

# Work even if somebody does "sh thisscript.sh".
set -e

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

# Get the variable from env.
PUBLIC_IP="$(cat env | egrep "PUBLIC_IP\s{0,}\=" | sed -E 's/\s+//g' | awk -F "=" '{print $2}')"
if [ -z $PUBLIC_IP ]; then
  # You can also use ifconfig.me, ifconfig.co and icanhazip.come for curl URLs.
  PUBLIC_IP="$(curl ifconfig.me)"
  sed -i -E -e "/PUBLIC_IP\s{0,}\=/{ s/\=.*/\= $PUBLIC_IP/; }" env
fi

#
# Main Script

#
# Setup Wizard
echo
PS3="Choose the next step. (1-3): "
select choice in "install" "uninstall" "quit"; do
  case $choice in
  "install")
    step1="install"
    break
    ;;
  "uninstall")
    step1="uninstall"
    break
    ;;
  "quit")
    exit
    ;;
  esac
done

#
# Install
if [ $step1 == "install" ]; then
  echo
  PS3="Choose the next step. (1-4): "
  select choice in "default" "laravel" "wordpress" "laravel + wordpress" "quit"; do
    case $choice in
    "default")
      step2="default"
      break
      ;;
    "laravel")
      step2="laravel"
      break
      ;;
    "wordpress")
      step2="wordpress"
      break
      ;;
    "laravel + wordpress")
      step2="laravel + wordpress"
      break
      ;;
    "quit")
      exit
      ;;
    esac
  done
fi

if [ $step1 == "install" ]; then
  echo
  create_vhostname=""
  while [[ -z "$create_vhostname" ]]; do
    read -p "Enter ServerName without an alias. (ex) example.com : " create_vhostname
    if [ -d /var/www/$create_vhostname ]; then
      echo $create_vhostname " already exists."
      read -p "Do you want to overwrite it? (y/n) " ansoverwrite
      case $ansoverwrite in
      y | Y)
        break
        ;;
      n | N)
        create_vhostname=""
        ;;
      esac
    fi
  done
fi

if [ $step1 == "install" ]; then
  printf "\n\nSetting up vhosting directory ... \n"
  if [ ! -d /var/www/$create_vhostname/html ]; then
    mkdir -p /var/www/$create_vhostname/html
  fi
  if [ ! -d /var/www/$create_vhostname/logs ]; then
    mkdir -p /var/www/$create_vhostname/logs
  fi
  chown -R www-data:www-data /var/www/$create_vhostname
  chmod -R 775 /var/www/$create_vhostname
fi

if [ $step1 == "install" ]; then
  printf "\n\nCreating new vhosting files ... \n"
  cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/$create_vhostname.conf
  cat >/etc/apache2/sites-available/$create_vhostname.conf <<VHOSTCONFSCRIPT
<VirtualHost *:80>
    ServerAdmin sys@_temp
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
VHOSTCONFSCRIPT

  if [ $step2 == "laravel" ]; then
    sed -i -E "/DocumentRoot/{ s#_temp/html#_temp/html/public#; }"
  fi

  dots=$(echo "$create_vhostname" | tr -cd . | wc -c)
  if [ $dots -gt 1 ]; then
    if egrep -q "/ServerAlias\s+www\._temp/" /etc/apache2/sites-available/$create_vhostname.conf; then
      sed -i -E "/ServerAlias\s+www\._temp/d" /etc/apache2/sites-available/$create_vhostname.conf
    fi
  fi

  sed -i -E "s/_temp/$create_vhostname/" /etc/apache2/sites-available/$create_vhostname.conf

  printf "\n\nAdding $create_vhostname to the /etc/hosts file ... \n"
  if ! egrep -q "^$PUBLIC_IP\s+$create_vhostname$" /etc/hosts; then
    sed -i "2 a\\$PUBLIC_IP $create_vhostname" /etc/hosts
  fi

  printf "\n\nDisabling default vhosting ... \n"
  if a2query -s | egrep -q "000-default\s+"; then
    a2dissite 000-default.conf
    systemctl reload apache2
  fi

  printf "\n\nEnabling new vhosting ... \n"
  a2ensite $create_vhostname.conf

  printf "\n\nReloading apache2 ... \n"
  systemctl reload apache2
fi

#
# Install default
if [ $step1 == "install" ] && [ $step2 == "default" ]; then
  printf "\n\nInstalling default ... \n"
  cp /var/www/html/index.html /var/www/$create_vhostname/html/index.html
fi

#
# Install laravel
if [ $step1 == "install" ] && [ $step2 == "laravel" ]; then
  printf "\n\nInstalling laravel ... \n"
fi

#
# Install wordpress
if [ $step1 == "install" ] && [ $step2 == "wordpress" ]; then
  printf "\n\nInstalling wordpress ... \n"

  DB_NAME="${create_vhostname%%\.*}db"
  DB_PASS="$(openssl rand -base64 12)"

  mysql -uroot <<MYSQL_SCRIPT
CREATE DATABASE $DB_NAME;
CREATE USER '$DB_NAME'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_NAME'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

  echo "MySQL user created."
  echo "Username: $DB_NAME"
  echo "Password: $DB_PASS"

  cd /var/www/$create_vhostname/html

  wget https://wordpress.org/latest.zip

  unzip latest.zip

  rm latest.zip

  mv wordpress/* .

  rmdir wordpress

fi

#
# Install laravel and wordpress
if [ $step1 == "install" ] && [ $step2 == "laravel + wordpress" ]; then
  printf "\n\nInstalling laravel and wordpress ... \n"
fi

#
# Uninstall
if [ $step1 == "uninstall" ]; then
  remove_vhostname=""
  while [[ -z "$remove_vhostname" ]]; do
    read -p "Enter ServerName without an alias. (ex) example.com : " remove_vhostname
    if [ ! -d /var/www/$remove_vhostname ]; then
      echo $remove_vhostname " does not exists."
      remove_vhostname=""
    fi
  done
fi

if [ $step1 == "uninstall" ]; then
  read -p "Are you sure you want to remove it? (y/n) " answer
  case $answer in
  y | Y)
    answer_remove="YES"
    ;;
  n | N)
    answer_remove="NO"
    ;;
  esac
fi

if [ $step1 == "uninstall" ] && [ $answer_remove == "YES" ]; then
  printf "\n\nDisabling $remove_vhostname vhosting ... \n"
  a2dissite $remove_vhostname.conf

  printf "\n\nRemoving $remove_vhostname to the /etc/hosts file ... \n"
  if egrep -q "^$PUBLIC_IP\s+$remove_vhostname$" /etc/hosts; then
    sed -i -E "/^$PUBLIC_IP\s+$remove_vhostname$/d" /etc/hosts
  fi

  printf "\n\nRemoving $remove_vhostname directory ... \n"
  if [ -d /var/www/$remove_vhostname ]; then
    rm -rf /var/www/$remove_vhostname
  fi

  printf "\n\nReloading apache2 ... \n"
  systemctl reload apache2
fi
