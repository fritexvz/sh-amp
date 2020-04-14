#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/amp-usr.sh
# ./ubuntu/18.04/amp-usr.sh

# Check to see if script is being run as root
if [ "$(whoami)" != 'root' ]; then
  echo "You have no permission to run $0 as non-root user. Use sudo"
  exit
fi

set -e # Work even if somebody does "sh thisscript.sh".

# Selecting Step
PS3="Choose the next step. (1-5): "
select choice in "Create a new ftp user?" "Allow user's root access?" "Change user's password?" "Change user's home directory?" "Delete a exist user?"; do
  case $choice in
  "Create a new ftp user?")
    USER_STEP="create"
    break
    ;;
  "Allow user's root access?")
    USER_STEP="chroot"
    break
    ;;
  "Change user's password?")
    USER_STEP="passwd"
    break
    ;;
  "Change user's home directory?")
    USER_STEP="usrmod"
    break
    ;;
  "Delete a exist user?")
    USER_STEP="delete"
    break
    ;;
  esac
done

while [[ -z "$FTP_USERNAME" ]]; do
  read -p "username: " FTP_USERNAME
  if cut -d: -f1 /etc/passwd | fgrep -q "$FTP_USERNAME"; then
    echo "The user '$FTP_USERNAME' already exists."
    FTP_USERNAME=""
  fi
done

if [ $USER_STEP == "create" ]; then
  adduser $FTP_USERNAME
  if ! fgrep -q "$FTP_USERNAME" /etc/vsftpd.user_list; then
    echo "$FTP_USERNAME" | tee -a /etc/vsftpd.user_list
  fi
fi

if [ $USER_STEP == "chroot" ]; then
  while true; do
    echo
    read -p "Do you want to allow user's root access? (y/n)? " answer
    case $answer in
    y | Y)
      if ! fgrep -q "$FTP_USERNAME" /etc/vsftpd.chroot_list; then
        echo "$FTP_USERNAME" | tee -a /etc/vsftpd.chroot_list
      fi
      break
      ;;
    n | N)
      break
      ;;
    esac
  done
fi

if [ $USER_STEP == "passwd" ]; then
  while true; do
    echo
    read -p "Would you like to change user's password? (y/n)? " answer
    case $answer in
    y | Y)
      passwd "$FTP_USERNAME"
      break
      ;;
    n | N)
      break
      ;;
    esac
  done
fi

if [ $USER_STEP == "usrmod" ]; then
  while true; do
    echo
    read -p "Would you like to change user's home directory? (y/n)? " answer
    case $answer in
    y | Y)
      while [[ -z "$FTP_HOME" ]]; do
        read -p "user's home directory: " FTP_HOME
      done
      usermod -d "$FTP_HOME" "$FTP_USERNAME"
      chown '$USER:$USER' "$FTP_HOME"
      chown -R "$FTP_USERNAME" "$FTP_HOME"
      break
      ;;
    n | N)
      break
      ;;
    esac
  done
fi

if [ $USER_STEP == "delete" ]; then
  deluser --remove-home "$FTP_USERNAME"
  if fgrep -q "$FTP_USERNAME" /etc/vsftpd.user_list; then
    sed -i "/$FTP_USERNAME/d" /etc/vsftpd.user_list
  fi
  if fgrep -q "$FTP_USERNAME" /etc/vsftpd.chroot_list; then
    sed -i "/$FTP_USERNAME/d" /etc/vsftpd.chroot_list
  fi
fi

systemctl restart vsftpd
