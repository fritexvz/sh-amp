function username_exists() {
  if [ -z "$(cut -d: -f1 /etc/passwd | egrep "^$1$")" ]; then
    echo "The user '$1' does not exist."
    exists_username=""
    while [ -z "${exists_username}" ]; do
      read -p "username: " exists_username
      if [ -z "$(cut -d: -f1 /etc/passwd | egrep "^${exists_username}$")" ]; then
        echo "The user '${exists_username}' does not exist."
        exists_username=""
      fi
    done
  else
    exists_username="$1"
  fi
}

function username_create() {
  if cut -d: -f1 /etc/passwd | egrep -q "^$1$"; then
    echo "The user '$1' already exists."
    create_username=""
    while [ -z "${create_username}" ]; do
      read -p "username: " create_username
      if [ ! -z "$(cut -d: -f1 /etc/passwd | egrep "^${create_username}$")" ]; then
        echo "The user '${create_username}' already exists."
        create_username=""
      fi
    done
  else
    create_username="$1"
  fi
}
