#!/bin/sh

mkdir -p /run/nginx

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -subj "/C=FR/ST=75/L=Paris/O=42/CN=adelcros"    \
    -keyout /etc/ssl/private/nginx-selfsigned.key   \
    -out /etc/ssl/certs/nginx-selfsigned.crt

# Replace IP and ports
sed -i s/__IP__/$IP/g           /etc/nginx/conf.d/default.conf
sed -i s/__WPPORT__/$WPPORT/g   /etc/nginx/conf.d/default.conf
sed -i s/__PMAPORT__/$PMAPORT/g /etc/nginx/conf.d/default.conf

nginx
telegraf &

while sleep 60; do
    ps aux |grep nginx |grep -q -v grep
    PROCESS_1_STATUS=$?
    ps aux |grep telegraf |grep -q -v grep
    PROCESS_2_STATUS=$?
    if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 ];
    then
        echo "One of the processes has already exited."
        exit 1
    fi
done
