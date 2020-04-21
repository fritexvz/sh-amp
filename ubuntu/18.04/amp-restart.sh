#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/amp-restart.sh
# ./ubuntu/18.04/amp-restart.sh

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

PS3="Choose the next step. (1-6): "
select choice in "apache2" "ufw" "fail2ban" "vsftpd" "mariadb" "quit"; do
  case $choice in
  "apache2")
    step="apache2"
    break
    ;;
  "ufw")
    step="ufw"
    break
    ;;
  "fail2ban")
    step="fail2ban"
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

if [ $step == "fail2ban" ]; then
  printf "\n\nRestarting fail2ban ... \n"
  service fail2ban restart
fi

if [ $step == "vsftpd" ]; then
  printf "\n\nRestarting vsftpd ... \n"
  systemctl restart vsftpd
fi

if [ $step == "mariadb" "mariadb" ]; then
  printf "\n\nRestarting mariadb ... \n"
  service mysqld restart
fi
