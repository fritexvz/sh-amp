#
# Database
# https://unix.stackexchange.com/questions/428158/drop-user-if-exists-syntax-error-in-mysql-cli
#
# Via command line
#mysql -uroot -e "SHOW DATABASES;"
#mysql -uroot -e "SELECT User FROM mysql.user;"

function create_database() {
  mysql -uroot -e "CREATE DATABASE IF NOT EXISTS $1;"
  mysql -uroot -e "CREATE USER IF NOT EXISTS '$2'@'localhost' IDENTIFIED BY '$3';"
  mysql -uroot -e "GRANT ALL PRIVILEGES ON $1.* TO '$2'@'localhost';"
  mysql -uroot -e "FLUSH PRIVILEGES;"
  echo
  echo "The database has been created."
  echo "database: $1"
  echo "Username: $2"
  echo "Password: $3"
}

function delete_database() {
  mysql -uroot -e "DROP DATABASE IF EXISTS $1;"
  mysql -uroot -e "DROP USER IF EXISTS '$2'@'localhost';"
  mysql -uroot -e "FLUSH PRIVILEGES;"
  echo
  echo "The database has been deleted."
}

function isDb() {
  mysql -uroot -e 'SHOW DATABASES;' | egrep "^$1$"
}

function isDbUser() {
  mysql -uroot -e 'SELECT User FROM mysql.user;' | egrep "^$1$"
}