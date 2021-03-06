#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/vsftpd/wizard.sh
# ./ubuntu/18.04/vsftpd/wizard.sh

# Work even if somebody does "sh thisscript.sh".
set -e

# Set a relative path.
FILENAME="$(basename $0)"
PKGPATH="$(dirname $0)"
PKGNAME="$(basename "${PKGPATH}")"
OSPATH="$(dirname "${PKGPATH}")"
LIBPATH="${PKGPATH}/lib"
TMPLPATH="${PKGPATH}/tmpl"

# Set absolute path.
ABSROOT="$(cd "$(dirname "")" && pwd)"
ABSENV="${ABSROOT}/env"
ABSOS="${ABSROOT}/${OSPATH}"
ABSPKG="${ABSOS}/${PKGNAME}"
ABSLIB="${ABSPKG}/lib"
ABSTMPL="${ABSPKG}/tmpl"
ABSPATH="${ABSPKG}/${FILENAME}"

# Include the file.
source "${ABSOS}/constants.sh"
source "${ABSOS}/utils.sh"
source "${ABSOS}/functions.sh"

# Make sure the package is installed.
pkgAudit "${PKGNAME}"

echo
echo "Start the ${PKGNAME} wizard."

# Run the command wizard.
COMMANDS=(
  "status"
  "start"
  "stop"
  "reload"
  "restart"
  "enable"
  "disable"
  "quit"
)
echo
IFS=$'\n'
PS3="Please select one of the options. (1-${#COMMANDS[@]}): "
select COMMAND in ${COMMANDS[@]}; do
  case "${COMMAND}" in
  "${COMMANDS[0]}")
    systemctl status vsftpd
    echo "${PKGNAME^} state loaded."
    ;;
  "${COMMANDS[1]}")
    systemctl start vsftpd
    echo "${PKGNAME^} started."
    ;;
  "${COMMANDS[2]}")
    systemctl stop vsftpd
    echo "${PKGNAME^} has stopped."
    ;;
  "${COMMANDS[3]}")
    systemctl reload vsftpd
    echo "${PKGNAME^} was refreshed."
    ;;
  "${COMMANDS[4]}")
    systemctl restart vsftpd
    echo "${PKGNAME^} restarted."
    ;;
  "${COMMANDS[5]}")
    systemctl enable vsftpd
    echo "${PKGNAME^} is enabled."
    ;;
  "${COMMANDS[6]}")
    systemctl disable vsftpd
    echo "${PKGNAME^} is disabled."
    ;;
  "${COMMANDS[7]}")
    exit 0
    ;;
  esac
done

echo
echo "Exit the ${PKGNAME} wizard."
