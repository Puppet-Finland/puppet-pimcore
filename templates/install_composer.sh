###################################################################################
# This file is managed by puppet.                                                 #
#                                                                                 #
# Source:                                                                         #
#    https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md #
#                                                                                 #
###################################################################################
#!/bin/sh

EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]
then
    >&2 echo 'ERROR: Invalid installer checksum'
    rm composer-setup.php
    exit 1
fi

php composer-setup.php --quiet
RESULT=$?
rm composer-setup.php

if [ $? -ne 0 ]; then
  >&2 echo 'ERROR: composer-setup.php failed!'
  exit $RESULT
fi

# This code was added to move created file to bin
mv ./composer.phar /usr/local/bin/composer || exit 1
exit 0
