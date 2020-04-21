#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/amp-fail2ban.sh
# ./ubuntu/18.04/amp-fail2ban.sh

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

PS3="Choose the next step. (1-5): "
select choice in "Restart fail2ban?" "Check the status?" "Unban the IP?" "Check the log?" "quit"; do
  case $choice in
  "Restart fail2ban?")
    step="restart"
    break
    ;;
  "Check the status?")
    step="status"
    break
    ;;
  "Unban the IP?")
    step="unbanip"
    break
    ;;
  "Check the log?")
    step="log"
    break
    ;;
  "quit")
    exit
    ;;
  esac
done

if [ $step == "restart" ]; then
  service fail2ban restart
fi

if [ $step == "status" ]; then
  fail2ban-client status sshd
fi

if [ $step == "unbanip" ]; then
  banip=""
  while [[ -z "$banip" ]]; do
    read -p "Unban IP : " banip
  done
  if grep -q $banip /etc/vsftpd.conf; then
    fail2ban-client set sshd unbanip $banip
  else
    echo "$banip is not blocked."
  fi
fi

if [ $step == "log" ]; then
  tail -f /var/log/fail2ban.log
fi
