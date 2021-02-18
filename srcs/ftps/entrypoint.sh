#!/bin/sh

# Create ssl certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -subj "/C=FR/ST=75/L=Paris/O=42/CN=adelcros"    \
    -keyout /etc/ssl/private/vsftpd.key   \
    -out /etc/ssl/certs/vsftpd.crt

# Adding user
adduser -D $FTP_USER && echo "$FTP_USER:$FTP_PASSWD" | chpasswd
chown -R $FTP_USER /home/$FTP_USER

# Apply external ip
sed -i s/__IP__/$IP/g /etc/vsftpd/vsftpd.conf

# Start vsftpd
vsftpd /etc/vsftpd/vsftpd.conf &

# Start telegraf
telegraf &

while sleep 60; do
    ps aux |grep vsftpd |grep -q -v grep
    PROCESS_1_STATUS=$?
    ps aux |grep telegraf |grep -q -v grep
    PROCESS_2_STATUS=$?
    if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 ];
    then
        echo "One of the processes has already exited."
        exit 1
    fi
done
