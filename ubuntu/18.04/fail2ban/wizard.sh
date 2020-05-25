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

# Make sure the package is installed.
pkgAudit "${PKGNAME}"

echo
echo "Start the ${PKGNAME} wizard."

# Run the command wizard.
COMMANDS=(
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
PS3="Please select one of the options. (1-${#COMMANDS[@]}): "
select COMMAND in ${COMMANDS[@]}; do
  case "${COMMAND}" in
  "${COMMANDS[0]}")
    # "restart"
    service fail2ban restart
    echo "${PKGNAME^} restarted."
    ;;
  "${COMMANDS[1]}")
    # "status"
    fail2ban-client status sshd
    echo "${PKGNAME^} state loaded."
    ;;
  "${COMMANDS[2]}")
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
  "${COMMANDS[3]}")
    # "destemail"
    echo "$(cat /etc/fail2ban/jail.local | egrep "destemail\s{0,}=")"
    DESTEMAIL="$(msg -ync -c 'destemail = ')"
    if [ ! -z "${DESTEMAIL}" ]; then
      sed -i -E \
        -e "/\[DEFAULT\]/,/\[.*\]/{ s/^[#\t ]{0,}(destemail\s{0,}=)/\1 ${DESTEMAIL}/; }" \
        /etc/fail2ban/jail.local
    fi
    echo "Destmail has been changed."
    ;;
  "${COMMANDS[4]}")
    # "sender"
    echo "$(cat /etc/fail2ban/jail.local | egrep "sender\s{0,}=")"
    SENDMAIL="$(msg -ync -c 'sender = ')"
    if [ ! -z "${SENDMAIL}" ]; then
      sed -i -E \
        -e "/\[DEFAULT\]/,/\[.*\]/{ s/^[#\t ]{0,}(sender\s{0,}=)/\1 ${SENDMAIL}/; }" \
        /etc/fail2ban/jail.local
    fi
    echo "Sender has been changed."
    ;;
  "${COMMANDS[5]}")
    # "log"
    tail -f /var/log/fail2ban.log
    echo "The log is loaded."
    ;;
  "${COMMANDS[6]}")
    # "quit"
    exit 0
    ;;
  esac
done

echo
echo "Exit the ${PKGNAME} wizard."
