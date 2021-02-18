#!/bin/sh

influxd &
telegraf &

while sleep 60; do
    ps aux |grep influxd |grep -q -v grep
    PROCESS_1_STATUS=$?
    ps aux |grep telegraf |grep -q -v grep
    PROCESS_2_STATUS=$?
    if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 ];
    then
        echo "One of the processes has already exited."
        exit 1
    fi
done