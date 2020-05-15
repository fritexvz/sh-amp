#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/fail2ban/wizard.sh
# ./ubuntu/18.04/fail2ban/wizard.sh

# Work even if somebody does "sh thisscript.sh".
set -e

# Set constants in the file.
ENVPATH=""
ABSPATH=""
DIRNAME=""
OS_PATH=""
PKGNAME=""

# Set the arguments of the file.
for arg in "${@}"; do
  case "${arg}" in
  --ENVPATH=*)
    ENVPATH="$(echo "${arg}" | sed -E 's/(--ENVPATH=)//')"
    ;;
  --ABSPATH=*)
    ABSPATH="$(echo "${arg}" | sed -E 's/(--ABSPATH=)//')"
    DIRNAME="$(dirname "${ABSPATH}")"
    OS_PATH="$(dirname "${DIRNAME}")"
    PKGNAME="$(basename "${DIRNAME,,}")"
    ;;
  esac
done

# Include the file.
source "${OS_PATH}/utils.sh"
source "${OS_PATH}/functions.sh"
source "${DIRNAME}/functions.sh"

# Make sure the package is installed.
pkgAudit "${PKGNAME}"

# Run the command wizard.
FAQS=(
  "restart"
  "status"
  "unbanip"
  "destemail"
  "sender"
  "log"
  "quit"
)

echo
IFS=$'\n'
PS3="Please select one of the options. (1-${#FAQS[@]}): "
select choice in ${FAQS[@]}; do
  case "${choice}" in
  "${FAQS[0]}")
    # "restart"
    service fail2ban restart
    echo "${PKGNAME^} restarted."
    ;;
  "${FAQS[1]}")
    # "status"
    fail2ban-client status sshd
    echo "${PKGNAME^} state loaded."
    ;;
  "${FAQS[2]}")
    # "unbanip"
    banip=""
    while [ -z "$banip" ]; do
      read -p "Unban IP : " banip
      if [ -z "$(iptables -L INPUT -v -n | grep "$banip")" ]; then
        echo "$banip is not blocked."
        banip=""
      fi
    done
    fail2ban-client set sshd unbanip "$banip"
    echo "IP unlocked."
    ;;
  "${FAQS[3]}")
    # "destemail"
    echo "$(cat /etc/fail2ban/jail.local | egrep "destemail\s{0,}=")"
    msgYn="$(msg -yn 'Would you like to change? (y/n) ')"
    if [ "${msgYn}" == "Yes" ]; then
      DESTEMAIL="$(msg -ync -p1='destemail = ' -p2='Are you sure you want to save the changes? (y/n/c) ')"
      if [ ! -z "${DESTEMAIL}" ]; then
        sed -i -E \
          -e "/\[DEFAULT\]/,/\[.*\]/{ s/^[# ]{0,}(destemail\s{0,}=)/\1 ${DESTEMAIL}/; }" \
          /etc/fail2ban/jail.local
      fi
    fi
    echo "Destmail has been changed."
    ;;
  "${FAQS[4]}")
    # "sender"
    echo "$(cat /etc/fail2ban/jail.local | egrep "sender\s{0,}=")"
    msgYn="$(msg -yn 'Would you like to change? (y/n) ')"
    if [ "${msgYn}" == "Yes" ]; then
      SENDMAIL="$(msg -ync -p1='sender = ' -p2='Are you sure you want to save the changes? (y/n/c) ')"
      if [ ! -z "${SENDMAIL}" ]; then
        sed -i -E \
          -e "/\[DEFAULT\]/,/\[.*\]/{ s/^[# ]{0,}(sender\s{0,}=)/\1 ${SENDMAIL}/; }" \
          /etc/fail2ban/jail.local
      fi
    fi
    echo "Sender has been changed."
    ;;
  "${FAQS[5]}")
    # "log"
    tail -f /var/log/fail2ban.log
    echo "The log is loaded."
    ;;
  "${FAQS[6]}")
    # "quit"
    exit 0
    ;;
  esac
done
