#!/bin/sh

# Setup WP
cd /var/www/wordpress
# Create config file
mv ./wp-config-sample.php ./wp-config.php
# Modify config file
sed -i "s/wp_/${WP_DB_TABLE_PREFIX}/"          wp-config.php
sed -i "s/database_name_here/${WP_DB_NAME}/"   wp-config.php
sed -i "s/password_here/${WP_DB_PASSWD}/"      wp-config.php
sed -i "s/username_here/${WP_DB_USER}/"        wp-config.php
sed -i "s/localhost/${WP_DB_HOST}/"            wp-config.php

# Try to establish a connection with database
TRIES=15
while :
do
    sleep 1
    wp core is-installed 2>&1 | (grep "Error establishing a database connection")
    if [[ $? = 0 ]]
    then
        TRIES=$((TRIES-1))
        echo $TRIES
        if [[ $TRIES = 0 ]]
        then
            echo "Could not connect to database !"
            exit 1
        fi
    else
        echo "Connection to database OK!"
        break
    fi
done

# Check whether WordPress is installed; exit status 0 if installed, otherwise 1
wp core is-installed
echo $?

# Bash script for checking whether WordPress is installed or not
if ! $(wp core is-installed); then
    wp core install --url=http://${WP_IP}:${WP_PORT} --title="wordpress adelcros" --admin_user=admin --admin_password=password --admin_email=admin@example.com --skip-email
    wp user create editor       editor@example.com      --role=editor       --user_pass=editor1
    wp user create author       author@example.com      --role=author       --user_pass=author1
    wp user create contributor  contributor@example.com --role=contributor  --user_pass=contributor1
    wp user create subscriber   subscriber@example.com  --role=subscriber   --user_pass=subscriber1
    wp theme install twentytwentyone
    wp theme activate twentytwentyone
fi

mkdir -p /run/nginx

# Start nginx
nginx

# Start php-fpm7
php-fpm7

# Start telegraf
telegraf &

# Naive check runs once a minute if any processes exited
# If it does, it loops forever, only waking up every minute to do another check
while sleep 60; do
    ps aux |grep nginx |grep -q -v grep
    PROCESS_1_STATUS=$?
    ps aux |grep php-fpm |grep -q -v grep
    PROCESS_2_STATUS=$?
    ps aux |grep telegraf |grep -q -v grep
    PROCESS_3_STATUS=$?
    # If they dont exit both with 0 status, then something is wrong
    if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 -o $PROCESS_3_STATUS -ne 0 ];
    then
        echo "One of the processes exited."
        exit 1
    fi
done