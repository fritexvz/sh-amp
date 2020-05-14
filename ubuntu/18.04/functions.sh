# Import variables from a configuration file.
#echo "$(getPkgCnf -rs="\[HOSTS\]" -fs="=" -s="PUBLIC_IP")"
function getPkgCnf() {

  local FILE="${ENVPATH}"
  local BEGIN_RECORD_SEPERATOR=""
  local END_RECORD_SEPERATOR="\[.*\]"
  local FIELD_SEPERATOR=""
  local SEARCH=""
  local MATCH="tail"

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
        echo "$(cat "${FILE}" | sed -E -n "/^${BEGIN_RECORD_SEPERATOR}/,/^${END_RECORD_SEPERATOR}/{
          /^[#; ]{0,}${SEARCH}\s{0,}${FIELD_SEPERATOR}/{
            /^[^#;]{1,}/ s/\s{0,}${FIELD_SEPERATOR}\s{0,}/${FIELD_SEPERATOR}/p;
          }
        }" | tail -1 | awk -F "${FIELD_SEPERATOR}" '{print $2}')"
      elif [ "${MATCH}" == "head" ]; then
        echo "$(cat "${FILE}" | sed -E -n "/^${BEGIN_RECORD_SEPERATOR}/,/^${END_RECORD_SEPERATOR}/{
          /^[#; ]{0,}${SEARCH}\s{0,}${FIELD_SEPERATOR}/{
            /^[^#;]{1,}/ s/\s{0,}${FIELD_SEPERATOR}\s{0,}/${FIELD_SEPERATOR}/p;
          }
        }" | head -1 | awk -F "${FIELD_SEPERATOR}" '{print $2}')"
      else
        echo "$(cat "${FILE}" | sed -E -n "/^${BEGIN_RECORD_SEPERATOR}/,/^${END_RECORD_SEPERATOR}/{
          /^[#; ]{0,}${SEARCH}\s{0,}${FIELD_SEPERATOR}/{
            /^[^#;]{1,}/ s/\s{0,}${FIELD_SEPERATOR}\s{0,}/${FIELD_SEPERATOR}/p;
          }
        }" | awk -F "${FIELD_SEPERATOR}" '{print $2}')"
      fi

    else

      if [ "${MATCH}" == "tail" ]; then
        echo "$(cat "${FILE}" | sed -E -n "/^${BEGIN_RECORD_SEPERATOR}/,/^${END_RECORD_SEPERATOR}/{
          /^[#; ]{0,}${SEARCH}\s{1,}/{ /^[^#;]{1,}/p }
        }" | tail -1 | awk '{print $2}')"
      elif [ "${MATCH}" == "head" ]; then
        echo "$(cat "${FILE}" | sed -E -n "/^${BEGIN_RECORD_SEPERATOR}/,/^${END_RECORD_SEPERATOR}/{
          /^[#; ]{0,}${SEARCH}\s{1,}/{ /^[^#;]{1,}/p }
        }" | head -1 | awk '{print $2}')"
      else
        echo "$(cat "${FILE}" | sed -E -n "/^${BEGIN_RECORD_SEPERATOR}/,/^${END_RECORD_SEPERATOR}/{
          /^[#; ]{0,}${SEARCH}\s{1,}/{ /^[^#;]{1,}/p }
        }" | awk '{print $2}')"
      fi

    fi

  else
    if [ ! -z "${FIELD_SEPERATOR}" ]; then

      if [ "${MATCH}" == "tail" ]; then
        echo "$(cat "${FILE}" | sed -E -n "/^[#; ]{0,}${SEARCH}s{0,}${FIELD_SEPERATOR}/{
          /^[^#;]{1,}/ s/\s{0,}${FIELD_SEPERATOR}\s{0,}/${FIELD_SEPERATOR}/p
        }" | tail -1 | awk -F "${FIELD_SEPERATOR}" '{print $2}')"
      elif [ "${MATCH}" == "head" ]; then
        echo "$(cat "${FILE}" | sed -E -n "/^[#; ]{0,}${SEARCH}s{0,}${FIELD_SEPERATOR}/{
          /^[^#;]{1,}/ s/\s{0,}${FIELD_SEPERATOR}\s{0,}/${FIELD_SEPERATOR}/p
        }" | head -1 | awk -F "${FIELD_SEPERATOR}" '{print $2}')"
      else
        echo "$(cat "${FILE}" | sed -E -n "/^[#; ]{0,}${SEARCH}s{0,}${FIELD_SEPERATOR}/{
          /^[^#;]{1,}/ s/\s{0,}${FIELD_SEPERATOR}\s{0,}/${FIELD_SEPERATOR}/p
        }" | awk -F "${FIELD_SEPERATOR}" '{print $2}')"
      fi

    else

      if [ "${MATCH}" == "tail" ]; then
        echo "$(cat "${FILE}" | sed -E -n "/^[#; ]{0,}${SEARCH}s{1,}/{ /^[^#;]{1,}/p }" | tail -1 | awk '{print $2}')"
      elif [ "${MATCH}" == "head" ]; then
        echo "$(cat "${FILE}" | sed -E -n "/^[#; ]{0,}${SEARCH}s{1,}/{ /^[^#;]{1,}/p }" | head -1 | awk '{print $2}')"
      else
        echo "$(cat "${FILE}" | sed -E -n "/^[#; ]{0,}${SEARCH}s{1,}/{ /^[^#;]{1,}/p }" | awk '{print $2}')"
      fi

    fi
  fi

}

# Edit the multiline string using here document.
#addPkgCnf -rs="\[PHP\]" -fs="=" -o="<<HERE
#...
#<<HERE"
function addPkgCnf() {

  local FILE="${ENVPATH}"
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

    if [ -z "${line}" ] || [ ! -z "$(echo "${line}" | egrep '^<<.*')" ]; then
      continue
    fi

    if [ ! -z "${FIELD_SEPERATOR}" ]; then
      SEARCH="$(echo "${line}" | sed -E 's/^[#; ]{1,}//' | awk -F "${FIELD_SEPERATOR}" '{print $1}')"
    else
      SEARCH="$(echo "${line}" | sed -E 's/^[#; ]{1,}//' | awk '{print $1}')"
    fi

    if [ ! -z "${BEGIN_RECORD_SEPERATOR}" ]; then
      if [ ! -z "${FIELD_SEPERATOR}" ]; then

        if [ "${MATCH}" == "tail" ]; then
          LINENUM="$(cat "${FILE}" | sed -E -n -e "/^${BEGIN_RECORD_SEPERATOR}/,/^${END_RECORD_SEPERATOR}/{
            /^[#; ]{0,}${SEARCH}\s{0,}${FIELD_SEPERATOR}/=;
          }" | tail -1)"
          if [ ! -z "${LINENUM}" ] || [ "${LINENUM}" != "0" ]; then
            sed -E -i -e "${LINENUM} c\\$(escapeQuote "${line}")" "${FILE}"
          fi
        elif [ "${MATCH}" == "head" ]; then
          LINENUM="$(cat "${FILE}" | sed -E -n -e "/^${BEGIN_RECORD_SEPERATOR}/,/^${END_RECORD_SEPERATOR}/{
            /^[#; ]{0,}${SEARCH}\s{0,}${FIELD_SEPERATOR}/=;
          }" | tail -1)"
          if [ ! -z "${LINENUM}" ] || [ "${LINENUM}" != "0" ]; then
            sed -E -i -e "${LINENUM} c\\$(escapeQuote "${line}")" "${FILE}"
          fi
        else
          sed -E -i -e "/^${BEGIN_RECORD_SEPERATOR}/,/^${END_RECORD_SEPERATOR}/{
            /^[#; ]{0,}${SEARCH}\s{0,}${FIELD_SEPERATOR}/{
              c\\$(escapeQuote "${line}")
            }
          }" "${FILE}"
        fi

      else

        if [ "${MATCH}" == "tail" ]; then
          LINENUM="$(cat "${FILE}" | sed -E -n -e "/^${BEGIN_RECORD_SEPERATOR}/,/^${END_RECORD_SEPERATOR}/{
            /^[#; ]{0,}${SEARCH}\s{1,}/=;
          }" | tail -1)"
          if [ ! -z "${LINENUM}" ] || [ "${LINENUM}" != "0" ]; then
            sed -E -i -e "${LINENUM} c\\$(escapeQuote "${line}")" "${FILE}"
          fi
        elif [ "${MATCH}" == "head" ]; then
          LINENUM="$(cat "${FILE}" | sed -E -n -e "/^${BEGIN_RECORD_SEPERATOR}/,/^${END_RECORD_SEPERATOR}/{
            /^[#; ]{0,}${SEARCH}\s{1,}/=;
          }" | head -1)"
          if [ ! -z "${LINENUM}" ] || [ "${LINENUM}" != "0" ]; then
            sed -E -i -e "${LINENUM} c\\$(escapeQuote "${line}")" "${FILE}"
          fi
        else
          sed -E -i -e "/^${BEGIN_RECORD_SEPERATOR}/,/^${END_RECORD_SEPERATOR}/{
            /^[#; ]{0,}${SEARCH}\s{1,}/{
              c\\$(escapeQuote "${line}")
            }
          }" "${FILE}"
        fi

      fi
    else
      if [ ! -z "${FIELD_SEPERATOR}" ]; then

        if [ "${MATCH}" == "tail" ]; then
          LINENUM="$(cat "${FILE}" | sed -E -n -e "/^[#; ]{0,}${SEARCH}\s{0,}${FIELD_SEPERATOR}/=;" | tail -1)"
          if [ ! -z "${LINENUM}" ] || [ "${LINENUM}" != "0" ]; then
            sed -E -i -e "${LINENUM} c\\$(escapeQuote "${line}")" "${FILE}"
          fi
        elif [ "${MATCH}" == "head" ]; then
          LINENUM="$(cat "${FILE}" | sed -E -n -e "/^[#; ]{0,}${SEARCH}\s{0,}${FIELD_SEPERATOR}/=;" | head -1)"
          if [ ! -z "${LINENUM}" ] || [ "${LINENUM}" != "0" ]; then
            sed -E -i -e "${LINENUM} c\\$(escapeQuote "${line}")" "${FILE}"
          fi
        else
          sed -i -E -e "/^[#; ]{0,}${SEARCH}\s{0,}${FIELD_SEPERATOR}/{
            c\\$(escapeQuote "${line}")
          }" "${FILE}"
        fi

      else

        if [ "${MATCH}" == "tail" ]; then
          LINENUM="$(cat "${FILE}" | sed -E -n -e "/^[#; ]{0,}${SEARCH}\s{1,}/=;" | tail -1)"
          if [ ! -z "${LINENUM}" ] || [ "${LINENUM}" != "0" ]; then
            sed -E -i -e "${LINENUM} c\\$(escapeQuote "${line}")" "${FILE}"
          fi
        elif [ "${MATCH}" == "head" ]; then
          LINENUM="$(cat "${FILE}" | sed -E -n -e "/^[#; ]{0,}${SEARCH}\s{1,}/=;" | head -1)"
          if [ ! -z "${LINENUM}" ] || [ "${LINENUM}" != "0" ]; then
            sed -E -i -e "${LINENUM} c\\$(escapeQuote "${line}")" "${FILE}"
          fi
        else
          sed -i -E -e "/^[#; ]{0,}${SEARCH}\s{1,}/{
            c\\$(escapeQuote "${line}")
          }" "${FILE}"
        fi

      fi
    fi

  done <<<"${OUTPUT}"

}

# Delete the variable from the env file.
#function delPkgCnf() {
#...
#}

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
  #delPkgCnf "..."

  # Upgrade your operating system to the latest.
  apt update && apt -y upgrade

}

# Make sure the package is installed.
function pkgAudit() {
  local pkg="$1"
  if [ -z "$(is${pkg^})" ]; then
    echo "The ${pkg,,} package is not installed."
    local msg=""
    while [ -z "${msg}" ]; do
      read -p "Install ${pkg,,} package? (y/n) " msg
      case "${msg}" in
      y | Y)
        bash ${pkg,,}.sh --install
        break 2
        ;;
      n | N)
        exit
        ;;
      esac
    done
  fi
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

# You can also use ifconfig.me, ifconfig.co, checkip.amazonaws.com and icanhazip.come for curl URLs.
function addPubIPs() {
  addPkgCnf -rs="\[HOSTS\]" -fs="=" -o="<<HERE
PUBLIC_IP = $(curl ifconfig.me)
<<HERE"
}

function msg() {

  local param=""
  local prompt=""
  local p1=""
  local p2=""
  local a1=""
  local a2=""

  for arg in "${@}"; do
    case "${arg}" in
    -yn)
      param="yn"
      ;;
    -ync)
      param="ync"
      ;;
    -p1=* | --print1=*)
      p1="$(echo "${arg}" | sed -E 's/(-p1=|--print1=)//')"
      ;;
    -p2=* | --print2=*)
      prompt="2"
      p2="$(echo "${arg}" | sed -E 's/(-p2=|--print2=)//')"
      ;;
    *)
      p1="${arg}"
      ;;
    esac
  done

  if [ "${param}" == "yn" ]; then
    if [ "${prompt}" == "2" ]; then
      a1=""
      while [ -z "${a1}" ]; do
        read -p "${p1}" a1
        a2=""
        while [ -z "${a2}" ]; do
          read -p "${p2}" a2
          case "${a2}" in
          y | Y)
            echo "${a1}"
            break 2
            ;;
          n | N)
            a1=""
            break
            ;;
          *)
            a2=""
            ;;
          esac
        done
      done
    else
      a1=""
      while [ -z "${a1}" ]; do
        read -p "${p1}" a1
        case "${a1}" in
        y | Y)
          echo "Yes"
          break
          ;;
        n | N)
          echo "No"
          break
          ;;
        *)
          a1=""
          ;;
        esac
      done
    fi
  elif [ "${param}" == "ync" ]; then
    if [ "${prompt}" == "2" ]; then
      a1=""
      while [ -z "${a1}" ]; do
        read -p "${p1}" a1
        a2=""
        while [ -z "${a2}" ]; do
          read -p "${p2}" a2
          case "${a2}" in
          y | Y)
            echo "${a1}"
            break 2
            ;;
          n | N)
            a1=""
            break
            ;;
          c | C)
            break 2
            ;;
          *)
            a2=""
            ;;
          esac
        done
      done
    else
      a1=""
      while [ -z "${a1}" ]; do
        read -p "${p1}" a1
        case "${a1}" in
        y | Y)
          echo "Yes"
          break
          ;;
        n | N)
          echo "No"
          break
          ;;
        c | C)
          echo "Cancel"
          break
          ;;
        *)
          a1=""
          ;;
        esac
      done
    fi

  fi

}
