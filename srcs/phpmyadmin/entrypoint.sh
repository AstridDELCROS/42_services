#!/bin/sh

# phpmyadmin setup
mkdir -p /var/www/phpmyadmin

mv phpMyAdmin-5.0.4-all-languages.tar.gz phpmyadmin.tar.gz
tar xzf phpmyadmin.tar.gz --strip-components=1 -C /var/www/phpmyadmin/

sed s/localhost/$WP_DB_HOST/g /var/www/phpmyadmin/config.sample.inc.php > /var/www/phpmyadmin/config.inc.php
# pour gérer reverse proxy
echo "\$cfg['PmaAbsoluteUri'] = './';" >> /var/www/phpmyadmin/config.inc.php

rm phpmyadmin.tar.gz

# Create ssl certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -subj "/C=FR/ST=75/L=Paris/O=42/CN=adelcros"    \
    -keyout /etc/ssl/private/nginx-selfsigned.key   \
    -out /etc/ssl/certs/nginx-selfsigned.crt

# Create this directory or change it in configs order to launch nginx
mkdir -p /run/nginx

nginx
php-fpm7
telegraf &

while sleep 60; do
    ps aux |grep nginx |grep -q -v grep
    PROCESS_1_STATUS=$?
    ps aux |grep php-fpm |grep -q -v grep
    PROCESS_2_STATUS=$?
    ps aux |grep telegraf |grep -q -v grep
    PROCESS_3_STATUS=$?
    if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 -o $PROCESS_3_STATUS -ne 0 ];
    then
        echo "One of the processes has already exited."
        exit 1
    fi
done