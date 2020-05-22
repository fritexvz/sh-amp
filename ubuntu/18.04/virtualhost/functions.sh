# https://unix.stackexchange.com/questions/428158/drop-user-if-exists-syntax-error-in-mysql-cli
function create_database() {
  mysql -uroot <<MYSQL_CREATE_SCRIPT
CREATE DATABASE \`$1\`;
CREATE USER \`$2\`@localhost IDENTIFIED BY \`$3\`;
GRANT ALL PRIVILEGES ON \`$1\`.* TO \`$2\`@localhost;
FLUSH PRIVILEGES;
MYSQL_CREATE_SCRIPT
  echo "The database has been created."
  echo "database: $1"
  echo "Username: $2"
  echo "Password: $3"
}

# https://unix.stackexchange.com/questions/428158/drop-user-if-exists-syntax-error-in-mysql-cli
function delete_database() {
  mysql -uroot <<MYSQL_DROP_SCRIPT
DROP DATABASE IF EXISTS \`$1\`;
DROP USER IF EXISTS \`$2\`@localhost;
FLUSH PRIVILEGES;
MYSQL_DROP_SCRIPT
  echo "The database has been deleted."
}

# https://unix.stackexchange.com/questions/428158/drop-user-if-exists-syntax-error-in-mysql-cli
function overwrite_database() {
  mysql -uroot <<MYSQL_CREATE_SCRIPT
DROP DATABASE IF EXISTS \`$1\`;
DROP USER IF EXISTS \`$2\`@localhost;
CREATE DATABASE \`$1\`;
CREATE USER \`$2\`@localhost IDENTIFIED BY \`$3\`;
GRANT ALL PRIVILEGES ON \`$1\`.* TO \`$2\`@localhost;
FLUSH PRIVILEGES;
MYSQL_CREATE_SCRIPT
  echo "The database has been created."
  echo "database: $1"
  echo "Username: $2"
  echo "Password: $3"
}
