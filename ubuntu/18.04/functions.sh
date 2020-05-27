# Import variables from a configuration file.
#echo "$(getPkgCnf -rs="\[HOSTS\]" -fs="=" -s="PUBLIC_IP")"
function getPkgCnf() {

  local FILE="${ABSENV}"
  local BEGIN_RECORD_SEPERATOR=""
  local END_RECORD_SEPERATOR="\[.*\]"
  local FIELD_SEPERATOR=""
  local SEARCH=""
  local MATCH="tail"
  local MATCHSTRING=""

  for arg in "${@}"; do
    case "${arg}" in
    -rs=* | --record-seperator=* | --IRS=*)
      BEGIN_RECORD_SEPERATOR="$(echo "${arg}" | sed -E 's/(-rs=|--record-seperator=|--IRS=)//')"
      ;;
    -es=* | --end-record-seperator=* | --ERS=*)
      END_RECORD_SEPERATOR="$(echo "${arg}" | sed -E 's/(-es=|--end-record-seperator=|--ERS=)//')"
      ;;
    -fs=* | --field-seperator=* | --IFS=*)
      FIELD_SEPERATOR="$(echo "${arg}" | sed -E 's/(-fs=|--field-seperator=|--IFS=*)//')"
      ;;
    -f=* | --file=* | --FILE=*)
      FILE="$(echo "${arg}" | sed -E 's/(-f=|--file=|--FILE=)//')"
      ;;
    -s=* | --search=* | --SEARCH=*)
      SEARCH="$(echo "${arg}" | sed -E 's/(-s=|--search=|--SEARCH=)//')"
      ;;
    -m=* | --match=* | --MATCH=*)
      MATCH="$(echo "${arg}" | sed -E 's/(-m=|--match=|--MATCH=)//')"
      ;;
    *)
      SEARCH="${arg}"
      ;;
    esac
  done

  if [ ! -f "${FILE}" ]; then
    echo "There is no ${FILE} file."
    return 0
  fi

  if [ ! -z "${BEGIN_RECORD_SEPERATOR}" ]; then
    if [ ! -z "${FIELD_SEPERATOR}" ]; then

      if [ "${MATCH}" == "tail" ]; then
        MATCHSTRING="$(cat "${FILE}" | sed -E -n "/^${BEGIN_RECORD_SEPERATOR}/,/^${END_RECORD_SEPERATOR}/{
          /^[#;\t ]{0,}${SEARCH}\s{0,}${FIELD_SEPERATOR}/{
            /^[^#;]{1,}/ s/\s{0,}${FIELD_SEPERATOR}\s{0,}/${FIELD_SEPERATOR}/p;
          }
        }" | tail -1)"
        echo "$(trim "$(removeComment "${MATCHSTRING}" | awk -F "${FIELD_SEPERATOR}" '{print $2}')")"
      elif [ "${MATCH}" == "head" ]; then
        MATCHSTRING="$(cat "${FILE}" | sed -E -n "/^${BEGIN_RECORD_SEPERATOR}/,/^${END_RECORD_SEPERATOR}/{
          /^[#;\t ]{0,}${SEARCH}\s{0,}${FIELD_SEPERATOR}/{
            /^[^#;]{1,}/ s/\s{0,}${FIELD_SEPERATOR}\s{0,}/${FIELD_SEPERATOR}/p;
          }
        }" | head -1)"
        echo "$(trim "$(removeComment "${MATCHSTRING}" | awk -F "${FIELD_SEPERATOR}" '{print $2}')")"
      else
        echo "$(cat "${FILE}" | sed -E -n "/^${BEGIN_RECORD_SEPERATOR}/,/^${END_RECORD_SEPERATOR}/{
          /^[#;\t ]{0,}${SEARCH}\s{0,}${FIELD_SEPERATOR}/{
            /^[^#;]{1,}/ s/\s{0,}${FIELD_SEPERATOR}\s{0,}/${FIELD_SEPERATOR}/p;
          }
        }" | sed -E 's/#.*//g' | awk -F "${FIELD_SEPERATOR}" '{print $2}' | sed -E 's/^[ \t\r\n]{1,}//g;s/[ \t\r\n]{1,}$//g;')"
      fi

    else

      if [ "${MATCH}" == "tail" ]; then
        MATCHSTRING="$(cat "${FILE}" | sed -E -n "/^${BEGIN_RECORD_SEPERATOR}/,/^${END_RECORD_SEPERATOR}/{
          /^[#;\t ]{0,}${SEARCH}\s{1,}/{ /^[^#;]{1,}/p }
        }" | tail -1)"
        echo "$(trim "$(removeComment "${MATCHSTRING}" | awk '{print $2}')")"
      elif [ "${MATCH}" == "head" ]; then
        MATCHSTRING="$(cat "${FILE}" | sed -E -n "/^${BEGIN_RECORD_SEPERATOR}/,/^${END_RECORD_SEPERATOR}/{
          /^[#;\t ]{0,}${SEARCH}\s{1,}/{ /^[^#;]{1,}/p }
        }" | head -1)"
        echo "$(trim "$(removeComment "${MATCHSTRING}" | awk '{print $2}')")"
      else
        echo "$(cat "${FILE}" | sed -E -n "/^${BEGIN_RECORD_SEPERATOR}/,/^${END_RECORD_SEPERATOR}/{
          /^[#;\t ]{0,}${SEARCH}\s{1,}/{ /^[^#;]{1,}/p }
        }" | sed -E 's/#.*//g' | awk '{print $2}' | sed -E 's/^[ \t\r\n]{1,}//g;s/[ \t\r\n]{1,}$//g;')"
      fi

    fi

  else
    if [ ! -z "${FIELD_SEPERATOR}" ]; then

      if [ "${MATCH}" == "tail" ]; then
        MATCHSTRING="$(cat "${FILE}" | sed -E -n "/^[#;\t ]{0,}${SEARCH}s{0,}${FIELD_SEPERATOR}/{
          /^[^#;]{1,}/ s/\s{0,}${FIELD_SEPERATOR}\s{0,}/${FIELD_SEPERATOR}/p
        }" | tail -1)"
        echo "$(trim "$(removeComment "${MATCHSTRING}" | awk -F "${FIELD_SEPERATOR}" '{print $2}')")"
      elif [ "${MATCH}" == "head" ]; then
        MATCHSTRING="$(cat "${FILE}" | sed -E -n "/^[#;\t ]{0,}${SEARCH}s{0,}${FIELD_SEPERATOR}/{
          /^[^#;]{1,}/ s/\s{0,}${FIELD_SEPERATOR}\s{0,}/${FIELD_SEPERATOR}/p
        }" | head -1)"
        echo "$(trim "$(removeComment "${MATCHSTRING}" | awk -F "${FIELD_SEPERATOR}" '{print $2}')")"
      else
        echo "$(cat "${FILE}" | sed -E -n "/^[#;\t ]{0,}${SEARCH}s{0,}${FIELD_SEPERATOR}/{
          /^[^#;]{1,}/ s/\s{0,}${FIELD_SEPERATOR}\s{0,}/${FIELD_SEPERATOR}/p
        }" | sed -E 's/#.*//g' | awk -F "${FIELD_SEPERATOR}" '{print $2}' | sed -E 's/^[ \t\r\n]{1,}//g;s/[ \t\r\n]{1,}$//g;')"
      fi

    else

      if [ "${MATCH}" == "tail" ]; then
        MATCHSTRING="$(cat "${FILE}" | sed -E -n "/^[#;\t ]{0,}${SEARCH}s{1,}/{ /^[^#;]{1,}/p }" | tail -1)"
        echo "$(trim "$(removeComment "${MATCHSTRING}" | awk '{print $2}')")"
      elif [ "${MATCH}" == "head" ]; then
        MATCHSTRING="$(cat "${FILE}" | sed -E -n "/^[#;\t ]{0,}${SEARCH}s{1,}/{ /^[^#;]{1,}/p }" | head -1)"
        echo "$(trim "$(removeComment "${MATCHSTRING}" | awk '{print $2}')")"
      else
        echo "$(cat "${FILE}" | sed -E -n "/^[#;\t ]{0,}${SEARCH}s{1,}/{ /^[^#;]{1,}/p }" | sed -E 's/#.*//g' | awk '{print $2}' | sed -E 's/^[ \t\r\n]{1,}//g;s/[ \t\r\n]{1,}$//g;')"
      fi

    fi
  fi

}

# Edit the string using here document.
#setPkgCnf -rs="\[PHP\]" -fs="=" -o="<<HERE
#...
#<<HERE"
function setPkgCnf() {

  local FILE="${ABSENV}"
  local BEGIN_RECORD_SEPERATOR=""
  local END_RECORD_SEPERATOR="\[.*\]"
  local FIELD_SEPERATOR=""
  local OUTPUT=""
  local SEARCH=""
  local MATCH="tail"
  local LINENUM=""

  for arg in "${@}"; do
    case "${arg}" in
    -rs=* | --record-seperator=* | --IRS=*)
      BEGIN_RECORD_SEPERATOR="$(echo "${arg}" | sed -E 's/(-rs=|--record-seperator=|--IRS=)//')"
      ;;
    -es=* | --end-record-seperator=* | --ERS=*)
      END_RECORD_SEPERATOR="$(echo "${arg}" | sed -E 's/(-es=|--end-record-seperator=|--ERS=)//')"
      ;;
    -fs=* | --field-seperator=* | --IFS=*)
      FIELD_SEPERATOR="$(echo "${arg}" | sed -E 's/(-fs=|--field-seperator=|--IFS=)//')"
      ;;
    -f=* | --file=* | --FILE=*)
      FILE="$(echo "${arg}" | sed -E 's/(-f=|--file=|--FILE=)//')"
      ;;
    -m=* | --match=* | --MATCH=*)
      MATCH="$(echo "${arg}" | sed -E 's/(-m=|--match=|--MATCH=)//')"
      ;;
    -o=* | --output=* | --OUTPUT=*)
      OUTPUT="$(echo "${arg}" | sed -E 's/(-o=|--output=|--OUTPUT=)//')"
      ;;
    *)
      OUTPUT="${arg}"
      ;;
    esac
  done

  if [ ! -f "${FILE}" ]; then
    echo "There is no ${FILE} file."
    return 0
  fi

  while IFS= read -r line; do

    if [ -z "${line}" ] ||
      [ ! -z "$(echo ${line} | sed -E -n '/^[<]{2}HERE/p')" ] ||
      [ ! -z "$(echo ${line} | sed -E -n '/^\[.*\]/p')" ] ||
      [ ! -z "$(echo ${line} | sed -E -n '/^[#;](\s|\t){1,}/p')" ]; then
      continue
    fi

    if [ ! -z "${FIELD_SEPERATOR}" ]; then
      SEARCH="$(echo "${line}" | sed -E 's/^[#;\t ]{1,}//;s/#.*//g;' | awk -F "${FIELD_SEPERATOR}" '{print $1}')"
      SEARCH="$(trim "${SEARCH}")"
    else
      SEARCH="$(echo "${line}" | sed -E 's/^[#;\t ]{1,}//;s/#.*//g;' | awk '{print $1}')"
      SEARCH="$(trim "${SEARCH}")"
    fi

    if [ -z "${SEARCH}" ]; then
      continue
    fi

    if [ ! -z "${BEGIN_RECORD_SEPERATOR}" ]; then
      if [ ! -z "${FIELD_SEPERATOR}" ]; then

        if [ "${MATCH}" == "tail" ]; then
          LINENUM="$(cat "${FILE}" | sed -E -n -e "/^${BEGIN_RECORD_SEPERATOR}/,/^${END_RECORD_SEPERATOR}/{
            /^[#;\t ]{0,}${SEARCH}\s{0,}${FIELD_SEPERATOR}/=;
          }" | tail -1)"
          if [ ! -z "${LINENUM}" ] && [ "${LINENUM}" -gt "0" ]; then
            sed -E -i -e "${LINENUM} c\\$(escapeQuote "${line}")" "${FILE}"
          fi
        elif [ "${MATCH}" == "head" ]; then
          LINENUM="$(cat "${FILE}" | sed -E -n -e "/^${BEGIN_RECORD_SEPERATOR}/,/^${END_RECORD_SEPERATOR}/{
            /^[#;\t ]{0,}${SEARCH}\s{0,}${FIELD_SEPERATOR}/=;
          }" | tail -1)"
          if [ ! -z "${LINENUM}" ] && [ "${LINENUM}" -gt "0" ]; then
            sed -E -i -e "${LINENUM} c\\$(escapeQuote "${line}")" "${FILE}"
          fi
        else
          sed -E -i -e "/^${BEGIN_RECORD_SEPERATOR}/,/^${END_RECORD_SEPERATOR}/{
            /^[#;\t ]{0,}${SEARCH}\s{0,}${FIELD_SEPERATOR}/{
              c\\$(escapeQuote "${line}")
            }
          }" "${FILE}"
        fi

      else

        if [ "${MATCH}" == "tail" ]; then
          LINENUM="$(cat "${FILE}" | sed -E -n -e "/^${BEGIN_RECORD_SEPERATOR}/,/^${END_RECORD_SEPERATOR}/{
            /^[#;\t ]{0,}${SEARCH}\s{1,}/=;
          }" | tail -1)"
          if [ ! -z "${LINENUM}" ] && [ "${LINENUM}" -gt "0" ]; then
            sed -E -i -e "${LINENUM} c\\$(escapeQuote "${line}")" "${FILE}"
          fi
        elif [ "${MATCH}" == "head" ]; then
          LINENUM="$(cat "${FILE}" | sed -E -n -e "/^${BEGIN_RECORD_SEPERATOR}/,/^${END_RECORD_SEPERATOR}/{
            /^[#;\t ]{0,}${SEARCH}\s{1,}/=;
          }" | head -1)"
          if [ ! -z "${LINENUM}" ] && [ "${LINENUM}" -gt "0" ]; then
            sed -E -i -e "${LINENUM} c\\$(escapeQuote "${line}")" "${FILE}"
          fi
        else
          sed -E -i -e "/^${BEGIN_RECORD_SEPERATOR}/,/^${END_RECORD_SEPERATOR}/{
            /^[#;\t ]{0,}${SEARCH}\s{1,}/{
              c\\$(escapeQuote "${line}")
            }
          }" "${FILE}"
        fi

      fi
    else
      if [ ! -z "${FIELD_SEPERATOR}" ]; then

        if [ "${MATCH}" == "tail" ]; then
          LINENUM="$(cat "${FILE}" | sed -E -n -e "/^[#;\t ]{0,}${SEARCH}\s{0,}${FIELD_SEPERATOR}/=;" | tail -1)"
          if [ ! -z "${LINENUM}" ] && [ "${LINENUM}" -gt "0" ]; then
            sed -E -i -e "${LINENUM} c\\$(escapeQuote "${line}")" "${FILE}"
          fi
        elif [ "${MATCH}" == "head" ]; then
          LINENUM="$(cat "${FILE}" | sed -E -n -e "/^[#;\t ]{0,}${SEARCH}\s{0,}${FIELD_SEPERATOR}/=;" | head -1)"
          if [ ! -z "${LINENUM}" ] && [ "${LINENUM}" -gt "0" ]; then
            sed -E -i -e "${LINENUM} c\\$(escapeQuote "${line}")" "${FILE}"
          fi
        else
          sed -i -E -e "/^[#;\t ]{0,}${SEARCH}\s{0,}${FIELD_SEPERATOR}/{
            c\\$(escapeQuote "${line}")
          }" "${FILE}"
        fi

      else

        if [ "${MATCH}" == "tail" ]; then
          LINENUM="$(cat "${FILE}" | sed -E -n -e "/^[#;\t ]{0,}${SEARCH}\s{1,}/=;" | tail -1)"
          if [ ! -z "${LINENUM}" ] && [ "${LINENUM}" -gt "0" ]; then
            sed -E -i -e "${LINENUM} c\\$(escapeQuote "${line}")" "${FILE}"
          fi
        elif [ "${MATCH}" == "head" ]; then
          LINENUM="$(cat "${FILE}" | sed -E -n -e "/^[#;\t ]{0,}${SEARCH}\s{1,}/=;" | head -1)"
          if [ ! -z "${LINENUM}" ] && [ "${LINENUM}" -gt "0" ]; then
            sed -E -i -e "${LINENUM} c\\$(escapeQuote "${line}")" "${FILE}"
          fi
        else
          sed -i -E -e "/^[#;\t ]{0,}${SEARCH}\s{1,}/{
            c\\$(escapeQuote "${line}")
          }" "${FILE}"
        fi

      fi
    fi

  done <<<"${OUTPUT}"

}

# Create backup and configuration files.
function addPkgCnf() {
  addDir "$(dirname "${ABSPKG}$1")"
  addFile "$1"
  cp -v "$1"{,.bak}
  cp -v "$1" "${ABSPKG}$1"
}

# Remove the package completely.
function delPkg() {

  # Delete the package.
  apt remove "$1*"
  apt purge "$1*"
  apt autoremove

  # If the directory still exists, delete it.
  if [ -d "/etc/$1" ]; then
    rm -rf "/etc/$1"
  fi

  # Delete the variable from the env file.
  setPkgCnf -rs="\[${1^^}\]" -fs="=" -o="<<HERE
${1^^}_VERSION = 
<<HERE"

  # Upgrade your operating system to the latest.
  apt update && apt -y upgrade

}

# Make sure the package is installed.
function pkgAudit() {
  if [ -z "$(is${1^})" ]; then
    echo "The ${1,,} package is not installed."
    exit 0
  fi
}

# Start the package and set it to start on boot.
function pkgOnBoot() {
  systemctl stop "$1"
  systemctl start "$1"
  systemctl enable "$1"
}

# Get a public IPv4 address.
function getPubIPs() {
  local IP="$(getPkgCnf -rs="\[HOSTS\]" -fs="=" -s="PUBLIC_IP")"
  if [ ! -z "${IP}" ]; then
    echo "${IP}"
  else
    addPubIPs
    getPubIPs
  fi
}

# You can also use ifconfig.me, ifconfig.co and checkip.amazonaws.com for curl URLs.
function addPubIPs() {
  local ip=""
  local ip1="$(curl ifconfig.me)"
  local ip2=""
  local ip3=""

  if [ ! -z "${ip1}" ]; then
    ip="${ip1}"
  else
    ip2="$(curl ifconfig.co)"
    if [ ! -z "${ip2}" ]; then
      ip="${ip2}"
    else
      ip3="$(curl checkip.amazonaws.com)"
      if [ ! -z "${ip3}" ]; then
        ip="${ip3}"
      fi
    fi
  fi

  setPkgCnf -rs="\[HOSTS\]" -fs="=" -o="<<HERE
PUBLIC_IP = ${ip}
<<HERE"
}

#
# Message box
#
# Usage
#
# Return: response string
# msg "something : "
# msg -p="something : "
#
# Return: Yes or No
# msg -yn "Am I hansome? (y/n) "
#
# Return: response string
# msg -c "something : "
# msg -c -p="something : "
# msg -yn -c "something : "
# msg -yn -c -p="something : "
# msg -yn -c="Keep going? (y/n) " "What is your name? "
# msg -yn -c="Keep going? (y/n) " -p="What is your name? "
#
# Return: Yes, No or Cancel
# msg -ync "Am I hansome? (y/n/c) "
#
# Return: response or empty string
# msg -ync -c "something : "
# msg -ync -c -p="something : "
# msg -ync -c="Keep going? (y/n/c) " "What is your name? "
# msg -ync -c="Keep going? (y/n/c) " -p="What is your name? "
#
function msg() {

  local response=""
  local confirm=""
  local prompt=""

  for arg in "${@}"; do
    case "${arg}" in
    -yn)
      response="(y/n)"
      ;;
    -ync)
      response="(y/n/c)"
      ;;
    -c)
      if [ -z "${response}" ]; then
        response="(y/n)"
      fi
      confirm="Are you sure? ${response} "
      ;;
    -c=* | --confirm=*)
      confirm="$(echo "${arg}" | sed -E 's/(-c=|--confirm=)//')"
      ;;
    -p=* | --prompt=*)
      prompt="$(echo "${arg}" | sed -E 's/(-p=|--prompt=)//')"
      ;;
    *)
      prompt="${arg}"
      ;;
    esac
  done

  # msg -c "What is your name? "
  if [ ! -z "${response}" ] && [ ! -z "${prompt}" ] && [ ! -z "${confirm}" ]; then

    if [ "${response}" == "(y/n/c)" ]; then
      # msg -ync -c "What is your name? "
      msgRequestYnc "${prompt}" "${confirm}"
    else
      # msg -yn -c "What is your name? "
      msgRequestYn "${prompt}" "${confirm}"
    fi

  # msg -yn "What is your name? "
  elif [ ! -z "${response}" ] && [ ! -z "${prompt}" ]; then

    if [ "${response}" == "(y/n/c)" ]; then
      # msg -ync "What is your name? "
      msgResponseYnc "${prompt}"
    else
      # msg -yn "What is your name? "
      msgResponseYn "${prompt}"
    fi

  # msg "What is your name? "
  else

    msgRequest "${prompt}"

  fi

}

function msgResponseYn() {
  local response=""
  while [ -z "${response}" ]; do
    read -p "$1" response
    case "${response}" in
    [yY][eE][sS] | [yY])
      response="Yes"
      break
      ;;
    [nN][oO] | [nN])
      response="No"
      break
      ;;
    *)
      response=""
      ;;
    esac
  done
  echo "${response}"
}

function msgResponseYnc() {
  local response=""
  while [ -z "${response}" ]; do
    read -p "$1" response
    case "${response}" in
    [yY][eE][sS] | [yY])
      response="Yes"
      break
      ;;
    [nN][oO] | [nN])
      response="No"
      break
      ;;
    [cC][aA][nN][cC][eE][lL] | [cC])
      response="Cancel"
      break
      ;;
    *)
      response=""
      ;;
    esac
  done
  echo "${response}"
}

function msgRequest() {
  local response=""
  while [ -z "${response}" ]; do
    read -p "$1" response
  done
  echo "${response}"
}

function msgRequestYn() {
  local response=""
  local confirm=""
  while [ -z "${response}" ]; do
    read -p "$1" response
    if [ ! -z "${response}" ]; then
      confirm=""
      while [ -z "${confirm}" ]; do
        read -p "$2" confirm
        case "${confirm}" in
        [yY][eE][sS] | [yY])
          break 2
          ;;
        [nN][oO] | [nN])
          response=""
          break
          ;;
        *)
          confirm=""
          ;;
        esac
      done
    fi
  done
  echo "${response}"
}

function msgRequestYnc() {
  local response=""
  local confirm=""
  while [ -z "${response}" ]; do
    read -p "$1" response
    if [ ! -z "${response}" ]; then
      confirm=""
      while [ -z "${confirm}" ]; do
        read -p "$2" confirm
        case "${confirm}" in
        [yY][eE][sS] | [yY])
          break 2
          ;;
        [nN][oO] | [nN])
          response=""
          break
          ;;
        [cC][aA][nN][cC][eE][lL] | [cC])
          response=""
          break 2
          ;;
        *)
          confirm=""
          ;;
        esac
      done
    fi
  done
  echo "${response}"
}
