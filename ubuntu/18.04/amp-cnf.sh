#!/bin/bash
#
# Download and run the latest release version.
# https://github.com/w3src/sh-amp
#
# Usage
# git clone https://github.com/w3src/sh-amp.git
# cd sh-amp
# chmod +x ./ubuntu/18.04/amp-cnf.sh
# ./ubuntu/18.04/amp-cnf.sh

# Check to see if script is being run as root
if [ "$(whoami)" != 'root' ]; then
  echo "You have no permission to run $0 as non-root user. Use sudo"
  exit
fi

set -e # Work even if somebody does "sh thisscript.sh".

printf "\n\nSetting up apache2 config ... \n"
printf "\n\nSetting up charset.conf ... \n"
if [ -f /etc/apache2/conf-available/charset.conf ]; then
  sed -i -E \
    -e "/AddDefaultCharset\s+\S+/{ s/^\#\s{0,}?//; }" \
    /etc/apache2/conf-available/charset.conf
fi

# This currently breaks the configurations that come with some web application Debian packages.
# Hide server version and virtual host name on the client.
# prevent MSIE from interpreting files as some else.
# This depends against clickjacking attacks.
printf "\n\nSetting up security.conf ... \n"
if [ -f /etc/apache2/conf-available/security.conf ]; then
  if ! egrep -q 'ServerTokens\s+Prod' /etc/apache2/conf-available/security.conf; then
    sed -i -E \
      -e "/ServerTokens\s+Full/a\ServerTokens Prod" \
      /etc/apache2/conf-available/security.conf
  fi
  sed -i -E \
    -e "8,11 s/\#//" \
    -e "/ServerTokens\s+OS/{ s/^/\#/; s/^\#+/\#/; }" \
    -e "/ServerTokens\s+Full/{ s/^/\#/; s/^\#+/\#/; }" \
    -e "/ServerTokens\s+Prod/{ s/^\#\s{0,}?//; }" \
    -e "/ServerSignature\s+On/{ s/^/\#/; s/^\#+/\#/; }" \
    -e "/ServerSignature\s+Off/{ s/^\#\s{0,}?//; }" \
    -e "/Header\s+set\s+X\-Content\-Type\-Options\s{0,}?\:/{ s/^\#\s{0,}?//; }" \
    -e "/Header\s+set\s+X\-Frame\-Options\s{0,}?\:/{ s/^\#\s{0,}?//; }" \
    /etc/apache2/conf-available/security.conf
fi

printf "\n\nSetting up apache2.conf ... \n"
if [ -f /etc/apache2/apache2.conf ]; then
  if ! egrep -q 'W3SRC DYNAMIC CONFIG' /etc/apache2/apache2.conf; then
    sed -i -e '$ i\
#\
#\
# W3SRC DYNAMIC CONFIG: START\
# Deny access to file and folder names beginning with dot.\
#<DirectoryMatch "^\.|\/\.">\
#  Require all denied\
#</DirectoryMatch>\
#\
# Deny access to file extensions(log file, binary, certificate, shell script, sql dump file).\
<FilesMatch "\.(?i:log|binary|pem|enc|crt|conf|cnf|sql|sh|key|yml|lock|gitignore)$">\
  Require all denied\
</FilesMatch>\
#\
# Deny access to file names.\
<FilesMatch "(?i:composer\.json|contributing\.md|license\.txt|readme\.rst|readme\.md|readme\.txt|copyright|artisan|gulpfile\.js|package\.json|phpunit\.xml|access_log|error_log|gruntfile\.js|bower\.json|changelog\.md|console|legalnotice|license|security\.md|privacy\.md)$">\
  Require all denied\
</FilesMatch>\
#\
# Allow Lets Encrypt Domain Validation Program.\
<DirectoryMatch "\.well-known/acme-challenge/">\
  Require all granted\
</DirectoryMatch>\
#\
# Block .php file inside upload folder. uploads(wp), files(drupal), data(gnuboard).\
<DirectoryMatch "/(uploads|default/files|data|wp-content/themes)/">\
  <FilesMatch ".+\.php$">\
    Require all denied\
  </FilesMatch>\
</DirectoryMatch>\
# W3SRC DYNAMIC CONFIG: END\
  ' /etc/apache2/apache2.conf
  fi
fi

# mpm-itk allows you to run each of your vhost under a separate uid and gid—in short, the scripts and configuration files for one vhost no longer have to be readable for all the other vhosts.
printf "\n\nSetting up permission ... \n"
apt-cache search mpm-itk
apt -y install libapache2-mpm-itk
chmod 711 /home
chmod -R 700 /home/*

# prefork MPM
# StartServers: number of server processes to start
# MinSpareServers: minimum number of server processes which are kept spare
# MaxSpareServers: maximum number of server processes which are kept spare
# MaxRequestWorkers: maximum number of server processes allowed to start
# MaxConnectionsPerChild: maximum number of requests a server process serves
printf "\n\nSetting up mpm_prefork.conf ... \n"

STARTSERVERS="5"
MAXREQUESTWORKERS="300"
MAXCONNECTIONSPERCHILD="0"

# StartServers
while true; do
  read -p "The default StartServers value is 5. Would you like to change? (y/n)? " answer
  case ${answer} in
  y | Y)
    STARTSERVERS=""
    while [[ -z "$STARTSERVERS" ]]; do
      read -p "StartServers: " STARTSERVERS
    done
    break
    ;;
  n | N)
    break
    ;;
  esac
done

# MaxRequestWorkers
while true; do
  read -p "The default MaxRequestWorkers value is 300. Would you like to change? (y/n)? " answer
  case ${answer} in
  y | Y)
    echo "The recommended server limits are 150 for 1G memory and 300 for 4G memory."
    MAXREQUESTWORKERS=""
    while [[ -z "$MAXREQUESTWORKERS" ]]; do
      read -p "MaxRequestWorkers: " MAXREQUESTWORKERS
    done
    break
    ;;
  n | N)
    break
    ;;
  esac
done

MINSPARESERVERS=$STARTSERVERS
MAXSPARESERVERS=$(($MINSPARESERVERS * 2))
SERVERLIMIT=$MAXREQUESTWORKERS

if [ -f /etc/apache2/mods-available/mpm_prefork.conf ]; then
  if ! egrep -q 'ServerLimit\s+' /etc/apache2/mods-available/mpm_prefork.conf; then
    sed -i -E \
      -e "/MaxRequestWorkers\s+/a\ServerLimit $SERVERLIMIT" \
      /etc/apache2/mods-available/mpm_prefork.conf
  fi
  sed -i -E \
    -e "s/^\s{0,}(StartServers)\s+.*/\1 $STARTSERVERS/" \
    -e "s/^\s{0,}(MinSpareServers)\s+.*/\1 $MINSPARESERVERS/" \
    -e "s/^\s{0,}(MaxSpareServers)\s+.*/\1 $MAXSPARESERVERS/" \
    -e "s/^\s{0,}(MaxRequestWorkers)\s+.*/\1 $MAXREQUESTWORKERS/" \
    -e "s/^\s{0,}(ServerLimit)\s+.*/\1 $SERVERLIMIT/" \
    -e "s/^\s{0,}(MaxConnectionsPerChild)\s+.*/\1 $MAXCONNECTIONSPERCHILD/" \
    /etc/apache2/mods-available/mpm_prefork.conf
fi

printf "\n\nRestarting apache2 ... \n"
systemctl restart apache2

printf "\n\nSetting up 000-default.conf ... \n"
if [ -f /etc/apache2/sites-available/000-default.conf ]; then
  sed -i -E \
    -e "s/\#\s{0,}(ServerName)\s+\S+/\1 localhost/" \
    /etc/apache2/sites-available/000-default.conf
fi

printf "\n\nSetting up 000-default-ssl.conf ... \n"
if [ -f /etc/apache2/sites-available/000-default-ssl.conf ]; then
  if ! egrep -q 'ServerName\s+' /etc/apache2/sites-available/000-default-ssl.conf; then
    sed -i -E \
      -e "/ServerAdmin\s+/i\ServerName localhost" \
      /etc/apache2/sites-available/000-default-ssl.conf
  fi
  sed -i -E \
    -e "s/(ServerName)\s+.*/\1 localhost/" \
    /etc/apache2/sites-available/000-default-ssl.conf
fi

printf "\n\nEnabling 000-default-ssl.conf ... \n"
a2ensite 000-default-ssl.conf
#a2dissite 000-default-ssl.conf

printf "\n\nReloading apache2 ... \n"
systemctl reload apache2

printf "\n\nSetting up mariadb config ... \n"
printf "\n\nSetting up 50-server.cnf ... \n"
if [ -f /etc/mysql/mariadb.conf.d/50-server.cnf ]; then
  sed -i -E \
    -e "/character\-set\-server\s{0,}?\=/{ s/\=.*/\= utf8mb4/; s/^\#\s{0,}?//; }" \
    -e "/collation\-server\s{0,}?\=/{ s/\=.*/\= utf8mb4\_unicode\_ci/; s/^\#\s{0,}?//; }" \
    /etc/mysql/mariadb.conf.d/50-server.cnf
fi

printf "\n\nSetting up my.cnf ... \n"
cat >/etc/my.cnf <<EOT
[client]
default-character-set = utf8mb4

[mysql]
default-character-set = utf8mb4

[mysqldump]
default-character-set = utf8mb4

[mysqld]
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
EOT

printf "\n\nRestarting mariadb ... \n"
service mysqld restart

printf "\n\nSetting up php config ... \n"

# Detect php version
PHP_VEROUT=$(php -v)
PHP_VERSION=$(expr substr "$PHP_VEROUT" 5 3)

# Tell the web server to prefer PHP files over others, so make Apache look for an index.php file first.
printf "\n\nSetting up dir.conf ... \n"
if [ -f /etc/apache2/mods-available/dir.conf ]; then
  sed -i -E \
    -e "/DirectoryIndex/{ s/\s+index.php//; }" \
    -e "/DirectoryIndex/{ s/index.html/index.php index.html/; }" \
    /etc/apache2/mods-available/dir.conf
fi

# Deny access to files without filename (e.g. '.php')
printf "\n\nSetting up php.conf ... \n"
if [ -f /etc/apache2/mods-available/php$PHP_VERSION.conf ]; then
  sed -i \
    -e '/<FilesMatch/{ s/ph(ar|p|tml)/ph(ar|p[3457]?|tml)/; }' \
    -e '/<FilesMatch/{ s/ph(ar|p|ps|tml)/ph(p[3457]?|t|tml|ps)/; }' \
    /etc/apache2/mods-available/php$PHP_VERSION.conf
fi

printf "\n\nSetting up php.ini ... \n"
MEMORY_LIMIT="256M"
POST_MAX_SIZE="1024M"
UPLOAD_MAX_FILESIZE="1024M"
MAX_EXECUTION_TIME="3600"
MAX_INPUT_TIME="3600"
MAX_INPUT_VARS="10000"
MAX_FILE_UPLOADS="100"
SHORT_OPEN_TAG="On"
TIMEZONE=$(cat /etc/timezone | sed 's/\//\\\//')

if [ -f /etc/php/$PHP_VERSION/apache2/php.ini ]; then
  sed -i -E \
    -e "/memory_limit\s{0,}?=/{ s/=.*/= $MEMORY_LIMIT/; s/^\;\s{0,}?//; }" \
    -e "/post_max_size\s{0,}?=/{ s/=.*/= $POST_MAX_SIZE/; s/^\;\s{0,}?//; }" \
    -e "/upload_max_filesize\s{0,}?=/{ s/=.*/= $UPLOAD_MAX_FILESIZE/; s/^\;\s{0,}?//; }" \
    -e "/max_execution_time\s{0,}?=/{ s/=.*/= $MAX_EXECUTION_TIME/; s/^\;\s{0,}?//; }" \
    -e "/max_input_time\s{0,}?=/{ s/=.*/= $MAX_INPUT_TIME/; s/^\;\s{0,}?//; }" \
    -e "/max_input_vars\s{0,}?=/{ s/=.*/= $MAX_INPUT_VARS/; s/^\;\s{0,}?//; }" \
    -e "/max_file_uploads\s{0,}?=/{ s/=.*/= $MAX_FILE_UPLOADS/; s/^\;\s{0,}?//; }" \
    -e "/short_open_tag\s{0,}?=/{ s/=.*/= $SHORT_OPEN_TAG/; s/^\;\s{0,}?//; }" \
    -e "/date.timezone\s{0,}?=/{ s/=.*/= $TIMEZONE/; s/^\;\s{0,}?//; }" \
    /etc/php/$PHP_VERSION/apache2/php.ini
fi

printf "\n\nRestarting apache2 ... \n"
systemctl restart apache2

printf "\n\nSetting up sendmail config ... \n"
printf "\n\nSetting up local-host-names ... \n"
if [ -f /etc/mail/local-host-names ]; then
  echo 'localhost' >/etc/mail/local-host-names
fi

printf "\n\nRestarting apache2 ... \n"
systemctl restart apache2

printf "\n\nSetting up vsftpd config ... \n"
if ! grep -q 'W3SRC DYNAMIC CONFIG' /etc/vsftpd.conf; then
  cat >>/etc/vsftpd.conf <<EOF
#
# W3SRC DYNAMIC CONFIG: START
#
# Chroot Jail
# To prevent the FTP users to access any files outside of their home directories uncomment the chroot setting.
# 500 OOPS: vsftpd: refusing to run with writable root inside chroot()
allow_writeable_chroot=YES
#
# Since Linux doesn’t show files beginning with a dot, files like .htaccess will not be visible in FTP.
# To force vsftpd to show file names that begin with a dot.
force_dot_files=YES
#
# Add some port ranges for passive FTP to make sure enough connections are available.
pasv_enable=YES
pasv_min_port=12000
pasv_max_port=12100
pasv_address=0.0.0.0/0
#
# Limiting User Login
# vsftpd will load a list of usernames, from the filename given by userlist_file
userlist_enable=YES
userlist_file=/etc/vsftpd.user_list
userlist_deny=NO
#
# After creating an ftp user, all files/folders were uploading with 711 to 755 permissions.
chmod_enable=YES
file_open_mode=0755
# 
# deny anonymous access over SSL:
#allow_anon_ssl=NO
#force_local_data_ssl=YES
#force_local_logins_ssl=YES
#
# server to use TLS:
#ssl_tlsv1=YES
#ssl_sslv2=NO
#ssl_sslv3=NO
#
# We will need high encrypted cipher suites meaning that the key lengths will be 128 bits or more
#require_ssl_reuse=NO
#ssl_ciphers=HIGH
#
# W3SRC DYNAMIC CONFIG: END
EOF
fi

# You can also use ifconfig.me, ifconfig.co and icanhazip.come for curl URLs.
IP_ADDR="$(curl ifconfig.me)"

if [ -f /etc/vsftpd.conf ]; then
  sed -i -E \
    -e "/listen\s{0,}?=/{ s/=.*/=YES/; s/^\#\s{0,}?//; }" \
    -e "/listen_ipv6\s{0,}?=/{ s/=.*/=NO/; s/^\#\s{0,}?//; }" \
    -e "/write_enable\s{0,}?=/{ s/=.*/=YES/; s/^\#\s{0,}?//; }" \
    -e "/local_umask\s{0,}?=/{ s/=.*/=002/; s/^\#\s{0,}?//; }" \
    -e "/xferlog_file\s{0,}?=/{ s/^\#\s{0,}?//; }" \
    -e "/chroot_local_user\s{0,}?=/{ s/^\#\s{0,}?//; }" \
    -e "/chroot_list_enable\s{0,}?=/{ s/^\#\s{0,}?//; }" \
    -e "/chroot_list_file\s{0,}?=/{ s/^\#\s{0,}?//; }" \
    -e "/connect_from_port_20\s{0,}?=/{ s/=.*/=YES/; s/^\#\s{0,}?//; }" \
    -e "/ssl_enable\s{0,}?=/{ s/=.*/=NO/; s/^\#\s{0,}?//; }" \
    -e "/pasv_address\s{0,}?=/{ s/=.*/\=$IP_ADDR/; }" \
    /etc/vsftpd.conf

  # Securing Transmissions with SSL/TLS
  if [ ! -f /etc/ssl/private/vsftpd.pem ]; then
    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /etc/ssl/private/vsftpd.pem -out /etc/ssl/private/vsftpd.pem
    openssl rsa -in /etc/ssl/private/vsftpd.pem -out /etc/ssl/private/vsftpd.key
  else
    while [[ -z "$ansrsa" ]]; do
      read -p "vsftpd.pem already exists. Would you like to overwrite it? (y/n) " ansrsa
      case $ansusrmod in
      y | Y)
        openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /etc/ssl/private/vsftpd.pem -out /etc/ssl/private/vsftpd.pem
        openssl rsa -in /etc/ssl/private/vsftpd.pem -out /etc/ssl/private/vsftpd.key
        break
        ;;
      n | N)
        break
        ;;
      esac
    done
  fi

  if [ -f /etc/ssl/private/vsftpd.pem ]; then
  sed -i -E \
    -e "/rsa_cert_file\s{0,}?=/{ s/=.*/=\/etc\/ssl\/private\/vsftpd.pem/; s/^\#\s{0,}?//; }" \
    -e "/rsa_private_key_file\s{0,}?=/{ s/=.*/=\/etc\/ssl\/private\/vsftpd.pem/; s/^\#\s{0,}?//; }" \
    -e "/ssl_enable\s{0,}?=/{ s/=.*/=YES/; s/^\#\s{0,}?//; }" \
    -e "/allow_anon_ssl\s{0,}?=/{ s/^\#\s{0,}?//; }" \
    -e "/force_local_data_ssl\s{0,}?=/{ s/^\#\s{0,}?//; }" \
    -e "/force_local_logins_ssl\s{0,}?=/{ s/^\#\s{0,}?//; }" \
    -e "/ssl_tlsv1\s{0,}?=/{ s/^\#\s{0,}?//; }" \
    -e "/ssl_sslv2\s{0,}?=/{ s/^\#\s{0,}?//; }" \
    -e "/ssl_sslv3\s{0,}?=/{ s/^\#\s{0,}?//; }" \
    -e "/require_ssl_reuse\s{0,}?=/{ s/^\#\s{0,}?//; }" \
    -e "/ssl_ciphers\s{0,}?=/{ s/^\#\s{0,}?//; }" \
    /etc/vsftpd.conf
  fi

fi

printf "\n\nDisabling Shell Access ... \n"
cat >/bin/ftponly <<EOT
#!/bin/sh
echo "This account is limited to FTP access only."
EOT

chmod a+x /bin/ftponly

if ! egrep -q "^\/bin\/ftponly$" /etc/shells; then
  echo "/bin/ftponly" | sudo tee -a /etc/shells
fi

printf "\n\nRestarting apache2 ... \n"
systemctl restart vsftpd
