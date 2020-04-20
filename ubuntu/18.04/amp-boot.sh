#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/amp-boot.sh
# ./ubuntu/18.04/amp-boot.sh

# Check to see if script is being run as root
if [ "$(whoami)" != 'root' ]; then
  echo "You have no permission to run $0 as non-root user. Use sudo"
  exit
fi

set -e # Work even if somebody does "sh thisscript.sh".

PS3="Choose the next step. (1-5): "
select choice in "apache2" "ufw" "vsftpd" "mariadb" "quit"; do
  case $choice in
  "apache2")
    step="apache2"
    break
    ;;
  "ufw")
    step="ufw"
    break
    ;;
  "vsftpd")
    step="vsftpd"
    break
    ;;
  "mariadb")
    step="mariadb"
    break
    ;;
  "quit")
    exit
    ;;
  esac
done

if [ $step == "apache2" ]; then
  printf "\n\nRestarting apache2 ... \n"
  systemctl restart apache2
fi

if [ $step == "ufw" ]; then
  printf "\n\nRestarting ufw ... \n"
  ufw disable
  ufw enable
fi

if [ $step == "vsftpd" ]; then
  printf "\n\nRestarting vsftpd ... \n"
  systemctl restart vsftpd
fi

if [ $step == "mariadb" ]; then
  printf "\n\nRestarting mariadb ... \n"
  service mysqld restart
fi
