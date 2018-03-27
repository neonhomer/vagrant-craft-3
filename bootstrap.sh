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
sudo apt-get -y install php-xdebug

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
sudo cp /etc/php/7.0/apache2/php.ini /etc/php/7.0/apache2/php.ini.bak
sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/apache2/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.0/apache2/php.ini
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = 16M/" /etc/php/7.0/apache2/php.ini

# Enable PHP Xdebug, log file is initially commented out
sudo sed -i "$ a\ \n[Xdebug]\nxdebug.remote_enable = 1\nxdebug.remote_autostart = 1\nxdebug.remote_connect_back = 1\n; xdebug.remote_log = /vagrant/xdebug.log" /etc/php/7.0/apache2/php.ini
echo "Edited php.ini"

# AllowOverride in apache
sudo cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf.bak
sudo sed -i "s/\tAllowOverride None/\tAllowOverride All/g" /etc/apache2/apache2.conf 
echo "Edited apache2.conf"

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

	# Craft adjustments
	# These are all optional

	# First back up general config
	sudo cp /vagrant/craft/config/general.php /vagrant/craft/config/general.php.bak
	# Use email as username
	sudo sed -i "s/'securityKey' => getenv('SECURITY_KEY'),/'securityKey' => getenv('SECURITY_KEY'),\n        'useEmailAsUsername' => true,/" /vagrant/craft/config/general.php
	# Add index file if none exist
	if ! [ -f /vagrant/craft/templates/index.twig ]; then
		sudo touch /vagrant/craft/templates/index.twig
		sudo printf "<html>\n<head></head>\n<body>\n{{ dump(_context) }}\n</body>\n</html>\n" > /vagrant/craft/templates/index.twig
	fi
	echo "Customized Craft CMS"
fi

# Set apache to use craft "web" folder
if ! [ -L /var/www/html ]; then
	sudo rm -rf /var/www/html
	sudo ln -fs /vagrant/craft/web /var/www/html
	echo "Symlinked craft/web folder"
fi
