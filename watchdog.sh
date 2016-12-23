#!/bin/bash

# Usage ./watchdog.sh PID TIMEOUT_MINUTES WATCHED_FILE

pid=$1
timeout=$2
file=$3

echo "Watchdog starting: PID: $pid, Timeout: $timeout, File: $file"

sleep $(expr $timeout \* 60)

while [[ ! -z $(find $file -mmin -$timeout -ls) ]]; do
  sleep 60
done

echo "Watchdog file($file) has not been updated within $timeout minutes - Killing process"

kill -9 $pid

