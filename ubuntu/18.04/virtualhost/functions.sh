# https://unix.stackexchange.com/questions/428158/drop-user-if-exists-syntax-error-in-mysql-cli
function create_database() {
  mysql -u root <<MYSQL_CREATE_SCRIPT
CREATE DATABASE \`$1\`;
CREATE USER \`$1\`@localhost IDENTIFIED BY \`${DBPASS}\`;
GRANT ALL PRIVILEGES ON \`$1\`.* TO \`$1\`@localhost;
FLUSH PRIVILEGES;
MYSQL_CREATE_SCRIPT
}

# https://unix.stackexchange.com/questions/428158/drop-user-if-exists-syntax-error-in-mysql-cli
function delete_database() {
  mysql -u root <<MYSQL_DROP_SCRIPT
DROP DATABASE IF EXISTS \`$1\`;
DROP USER IF EXISTS \`$1\`@localhost;
FLUSH PRIVILEGES;
MYSQL_DROP_SCRIPT
}

# https://unix.stackexchange.com/questions/428158/drop-user-if-exists-syntax-error-in-mysql-cli
function overwrite_database() {
  mysql -u root <<MYSQL_CREATE_SCRIPT
DROP DATABASE IF EXISTS \`$1\`;
DROP USER IF EXISTS \`$1\`@localhost;
CREATE DATABASE \`$1\`;
CREATE USER \`$1\`@localhost IDENTIFIED BY \`${DBPASS}\`;
GRANT ALL PRIVILEGES ON \`$1\`.* TO \`$1\`@localhost;
FLUSH PRIVILEGES;
MYSQL_CREATE_SCRIPT
}
