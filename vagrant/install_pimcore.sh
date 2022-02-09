#!/bin/bash
#
# Installs Pimcore
# Guide: https://pimcore.com/docs/pimcore/current/Development_Documentation/Getting_Started/Installation.html
#
set -e
PROJECT_DIR='/opt/pimcore'
COMPOSER_MEMORY_LIMIT=-1

if [ -d "$PROJECT_DIR" ]; then
  echo "Installing Pimcore..."
  cd "$PROJECT_DIR" && composer create-project pimcore/skeleton "$PROJECT_DIR"
  PIMCORE_INSTALL_MYSQL_USERNAME=pimcore PIMCORE_INSTALL_MYSQL_PASSWORD=supersecret \
    ./vendor/bin/pimcore-install --admin-username vagrant --admin-password vagrant \
    --mysql-database pimcore --no-interaction
  sudo ln -sf /shared/vagrant/config/domain.tld.conf /etc/apache2/sites-available/domain.tld.conf
  sudo chmod ug+x bin/*
  sudo ./bin/console assets:install
  sudo chown -R -h www-data:www-data var public
  sudo systemctl restart apache2
else
  echo "error: '$PROJECT_DIR' does not exist!"
fi
