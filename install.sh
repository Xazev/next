#!/bin/bash
apt-get install apache2 php7.2 bzip2
apt-get install libapache2-mod-php php-gd php-json php-mysql php-curl php-mbstring
apt-get install php-intl php-imagick php-xml php-zip

apt-get install mariadb-server php-mysql
mysql
CREATE DATABASE nextcloud;
CREATE USER 'nc_user'@'localhost' IDENTIFIED BY 'YOUR_PASSWORD_HERE';
GRANT ALL PRIVILEGES ON nextcloud.* TO 'nc_user'@'localhost';
FLUSH PRIVILEGES;

wget https://download.nextcloud.com/server/releases/latest-18.tar.bz2 -O nextcloud-18-latest.tar.bz2
tar -xvjf nextcloud-18-latest.tar.bz2
chown -R www-data:www-data nextcloud
rm nextcloud-18-latest.tar.bz2

cat >/etc/apache2/sites-available/nextcloud.conf <<EOT
<VirtualHost *:80>
ServerAdmin admin@domain.tld
DocumentRoot /var/www/nextcloud/
ServerName test.local.local
ServerAlias test.local.local
Alias /nextcloud "/var/www/nextcloud/"
 <Directory /var/www/nextcloud/>
   Options +FollowSymlinks
   AllowOverride All
   Require all granted
 <IfModule mod_dav.c>
   Dav off
</IfModule>
 SetEnv HOME /var/www/nextcloud
 SetEnv HTTP_HOME /var/www/nextcloud
</Directory>
ErrorLog ${APACHE_LOG_DIR}/error.log
CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOT

a2ensite nextcloud
a2enmod rewrite headers env dir mime
sed -i '/^memory_limit =/s/=.*/= 512M/' /etc/php/7.2/apache2/php.ini
systemctl restart apache2

ufw allow http
ufw allow https