#!/usr/bin/env bash

DATABASE='craft'
DATABASE_PASSWORD='password'

# Make sure linux stuff is up-to-date
sudo apt-get update

# Install Apache and PHP
sudo apt-get install -y apache2 libapache2-mod-php
sudo apt-get install -y php imagemagick php-imagick php-curl php-zip

# Install MySQL
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $DATABASE_PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DATABASE_PASSWORD"
sudo apt-get -y install mysql-server php-mysql

# Install PHPMyAdmin
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $DATABASE_PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $DATABASE_PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $DATABASE_PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
sudo apt-get -y install phpmyadmin

# Create database and changed settings for craft
sudo mysql -u root -p$DATABASE_PASSWORD -e "CREATE DATABASE $DATABASE;"
sudo mysql -u root -p$DATABASE_PASSWORD -e "ALTER DATABASE $DATABASE CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
sudo mysql -u root -p$DATABASE_PASSWORD -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION; FLUSH PRIVILEGES;"

# Turn on PHP errors and increase upload file size limit
sudo sed -i.bak "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/apache2/php.ini
sudo sed -i.bak "s/display_errors = .*/display_errors = On/" /etc/php/7.0/apache2/php.ini
sudo sed -i.bak "s/upload_max_filesize = .*/upload_max_filesize = 16M/" /etc/php/7.0/apache2/php.ini

# AllowOverride in apache
sudo sed -i.bak "s/\tAllowOverride None/\tAllowOverride All/g" /etc/apache2/apache2.conf 

# Enable mod_rewrite/mcrypt and restart Apache
sudo a2enmod rewrite
sudo phpenmod mcrypt
sudo service apache2 restart

# Install composer and install global (v1.6.2)
wget https://raw.githubusercontent.com/composer/getcomposer.org/1b137f8bf6db3e79a38a5bc45324414a6b1f9df2/web/installer -O - -q | php -- --quiet
sudo mv composer.phar /usr/bin/composer

# Install Craft CMS (if not already installed)
if ! [ -f /vagrant/craft/web/index.php ]; then
  composer create-project -s RC craftcms/craft /vagrant/craft
  # Set apache to use craft "web" folder
  sudo rm -rf /var/www/html
  sudo ln -fs /vagrant/craft/web /var/www/html
fi

# Craff setting adjustments

# Adjust local dev to use port number and set siteUrl
sudo sed -i.bak "s/return \[/\/\/ Define URL settings to use port numbers for local development\ndefine('URI_PORT', (\$_SERVER['SERVER_PORT'] == '80') ? '' : ':' . \$_SERVER['SERVER_PORT']);\ndefine('SITE_URL', 'http:\/\/' . \$_SERVER['SERVER_NAME'] . URI_PORT . '\/');\n\nreturn [/" /vagrant/craft/config/general.php
sudo sed -i.bak "s/'siteUrl' => null,/'siteUrl' => SITE_URL,/" /vagrant/craft/config/general.php
# Use email as username (optional)
sudo sed -i.bak "s/'securityKey' => getenv('SECURITY_KEY'),/'securityKey' => getenv('SECURITY_KEY'),\n        'useEmailAsUsername' => true,/" /vagrant/craft/config/general.php
