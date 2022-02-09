#!/bin/bash
#
# Installs All requirements for Pimcore
# Site: https://pimcore.com/docs/pimcore/current/Development_Documentation/Getting_Started/Installation.html
#
set -e
apt-get install -y software-properties-common
add-apt-repository ppa:ondrej/php
apt-get update -y

# INSTALL REQUIREMENTS
echo 'Installing Requirements...'
apt-get install -y php8.0 apache2 libapache2-mod-php8.0 php8.0-mysql php8.0-gd php8.0-xml php8.0-mbstring \
	php8.0-zip php8.0-intl php8.0-curl mysql-server composer
a2enmod rewrite
a2enmod ssl

# INSTALL RECOMMENDED SOFTWARE
echo 'Installing Recommended...'
apt-get install -y php8.0-imagick php8.0-redis redis

# INSTALL ADDITIONAL SOFTWARE
apt-get install -y ffmpeg ghostscript libreoffice wkhtmltopdf xvfb poppler-utils \
	inkscape libimage-exiftool-perl graphviz facedetect

wget https://github.com/imagemin/zopflipng-bin/blob/main/vendor/linux/zopflipng -O /usr/local/bin/zopflipng
wget https://github.com/imagemin/pngcrush-bin/blob/main/vendor/linux/pngcrush -O /usr/local/bin/pngcrush
wget https://github.com/imagemin/jpegoptim-bin/blob/main/vendor/linux/jpegoptim -O /usr/local/bin/jpegoptim
wget https://github.com/imagemin/pngout-bin/blob/main/vendor/linux/x64/pngout -O /usr/local/bin/pngout
wget https://github.com/imagemin/advpng-bin/blob/main/vendor/linux/advpng -O /usr/local/bin/advpng
wget https://github.com/imagemin/mozjpeg-bin/blob/main/vendor/linux/cjpeg -O /usr/local/bin/cjpeg
chmod 0755 /usr/local/bin/zopflipng
chmod 0755 /usr/local/bin/pngcrush
chmod 0755 /usr/local/bin/jpegoptim
chmod 0755 /usr/local/bin/pngout
chmod 0755 /usr/local/bin/advpng
chmod 0755 /usr/local/bin/cjpeg

# INSTALL COMPOSER
SHA384='756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3'
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === $SHA384) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php --install-dir=/usr/local/bin --filename=composer
php -r "unlink('composer-setup.php');"
mv 
#  CONFIGURE
echo 'Now Configuring...'
ln -sf /shared/vagrant/config/php.ini /etc/php/8.0/apache2/php.ini
ln -sf /shared/vagrant/config/redis.conf /etc/redis/redis.conf
ln -sf /opt/pimcore/public /var/www/html/pimcore
cp /shared/vagrant/config/pimcore.cnf /etc/mysql/conf.d/
mysql < /shared/vagrant/config/pimcore.sql
systemctl restart apache2 redis mysql

# PREP FOR PIMCORE
echo 'Finishing up...'
mkdir /opt/pimcore
chown vagrant:vagrant /opt/pimcore
