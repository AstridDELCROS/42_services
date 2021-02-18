#!/bin/sh

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
mysql_install_db --user=mysql --datadir=/var/lib/mysql/
sed -i 's/^skip-networking/#&/' /etc/my.cnf.d/mariadb-server.cnf

init_db.sh &

# Start mysql
/usr/bin/mysqld_safe --datadir="/var/lib/mysql/" &

telegraf &

while sleep 60; do
    ps aux |grep mysql |grep -q -v grep
    PROCESS_1_STATUS=$?
    ps aux |grep telegraf |grep -q -v grep
    PROCESS_2_STATUS=$?
    if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 ];
    then
        echo "One of the processes has already exited."
        exit 1
    fi
done
