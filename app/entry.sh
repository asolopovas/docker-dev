#!/bin/bash
# Start crond in background
crond -l 2 -b

if [ "$APP_ENV" == 'local' ]; then
    sudo cp -f "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini";
else
    sudo cp -f "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini";
fi

sudo sed -i -e "s/upload_max_filesize = 2M/upload_max_filesize = 64M/g" $PHP_INI_DIR/php.ini
sudo sed -i -e "s/post_max_size = 8M/post_max_size = 64M/g" $PHP_INI_DIR/php.ini
sudo sed -i -e "s/memory_limit = 128M/memory_limit = 256M/g" $PHP_INI_DIR/php.ini
sudo sed -i -e "s/;error_log = syslog/error_log = \/proc\/self\/fd\/2/g" $PHP_INI_DIR/php.ini

composer dumpautoload --no-scripts --optimize
if [ ! -f .env ]; then
  cp .env.example .env
fi

php artisan key:generate

exec sudo -u root php-fpm
