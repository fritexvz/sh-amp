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
    step="create"
    break
    ;;
  "Allow user's root access?")
    step="chroot"
    break
    ;;
  "Change user's password?")
    step="passwd"
    break
    ;;
  "Change user's home directory?")
    step="usrmod"
    break
    ;;
  "Delete a exist user?")
    step="delete"
    break
    ;;
  esac
done

while [[ -z "$username" ]]; do
  read -p "username: " username
done

if [ $step == "create" ]; then
  # check username
  if cut -d: -f1 /etc/passwd | egrep -q "^$username$"; then
    echo "The user '$username' already exists."
    while [[ -z "$create_username" ]]; do
      read -p "username: " create_username
      if cut -d: -f1 /etc/passwd | egrep -q "^$create_username$"; then
        echo "The user '$create_username' already exists."
        create_username=""
      fi
    done
  else
    create_username=username
  fi
  # do something
  adduser $create_username
  if ! egrep -q "^$create_username$" /etc/vsftpd.user_list; then
    echo "$create_username" | tee -a /etc/vsftpd.user_list
  else 
    echo "'$create_username' is already in user_list."
  fi
fi

if [ $step == "chroot" ]; then
  # check username
  if ! cut -d: -f1 /etc/passwd | egrep -q "^$username$"; then
    printf "The user '$username' does not exist."
    while [[ -z "$exists_username" ]]; do
      read -p "username: " exists_username
      if ! cut -d: -f1 /etc/passwd | egrep -q "^$exists_username$"; then
        printf "The user '$exists_username' does not exist."
        exists_username=""
      fi
    done
  else
    exists_username=username
  fi
  # do something
  while true; do
    echo
    read -p "Do you want to allow user's root access? (y/n)? " answer
    case $answer in
    y | Y)
      if ! egrep -q "^$exists_username$" /etc/vsftpd.chroot_list; then
        echo "$exists_username" | tee -a /etc/vsftpd.chroot_list
      else 
        echo "'$exists_username' is already in chroot_list."
      fi
      break
      ;;
    n | N)
      break
      ;;
    esac
  done
fi

if [ $step == "passwd" ]; then
  # check username
  if ! cut -d: -f1 /etc/passwd | egrep -q "^$username$"; then
    printf "The user '$username' does not exist."
    while [[ -z "$exists_username" ]]; do
      read -p "username: " exists_username
      if ! cut -d: -f1 /etc/passwd | egrep -q "^$exists_username$"; then
        printf "The user '$exists_username' does not exist."
        exists_username=""
      fi
    done
  else
    exists_username=username
  fi
  # do something
  while true; do
    echo
    read -p "Would you like to change user's password? (y/n)? " answer
    case $answer in
    y | Y)
      passwd "$exists_username"
      break
      ;;
    n | N)
      break
      ;;
    esac
  done
fi

if [ $step == "usrmod" ]; then
  # check username
  if ! cut -d: -f1 /etc/passwd | egrep -q "^$username$"; then
    printf "The user '$username' does not exist."
    while [[ -z "$exists_username" ]]; do
      read -p "username: " exists_username
      if ! cut -d: -f1 /etc/passwd | egrep -q "^$exists_username$"; then
        printf "The user '$exists_username' does not exist."
        exists_username=""
      fi
    done
  else
    exists_username=username
  fi
  # do something
  while true; do
    echo
    read -p "Would you like to change user's home directory? (y/n)? " answer
    case $answer in
    y | Y)
      while [[ -z "$userdir" ]]; do
        read -p "user's home directory: " userdir
        if [ ! -d $userdir ]; then
          echo "Directory does not exist."
          while true; do
            read -p "Do you want to make a directory? (y/n)? " ans
            case $ans in
              y | Y)
                mkdir -p $userdir
                break 2
                ;;
              n | N)
                userdir=""
                break
                ;;
            esac
          done
        fi
      done
      usermod -d "$userdir" "$exists_username"
      chown '$USER:$USER' "$userdir"
      chown -R "$exists_username" "$userdir"
      break
      ;;
    n | N)
      break
      ;;
    esac
  done
fi

if [ $step == "delete" ]; then
  # check username
  if ! cut -d: -f1 /etc/passwd | egrep -q "^$username$"; then
    printf "The user '$username' does not exist."
    while [[ -z "$exists_username" ]]; do
      read -p "username: " exists_username
      if ! cut -d: -f1 /etc/passwd | egrep -q "^$exists_username$"; then
        printf "The user '$exists_username' does not exist."
        exists_username=""
      fi
    done
  else
    exists_username=username
  fi
  # do something
  deluser --remove-home "$exists_username"
  if egrep -q "^$exists_username$" /etc/vsftpd.user_list; then
    sed -i "/$exists_username/d" /etc/vsftpd.user_list
  fi
  if egrep -q "^$exists_username$" /etc/vsftpd.chroot_list; then
    sed -i "/$exists_username/d" /etc/vsftpd.chroot_list
  fi
fi

systemctl restart vsftpd
