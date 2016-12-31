#!/bin/bash

# Usage ./watchdog.sh TIMEOUT_MINUTES WATCHED_FILE

timeout=$1
file=$2

oneMinute=60

echo "Watchdog starting: Timeout: $timeout, File: $file"

sleep $(expr $timeout \* $oneMinute)

while [[ ! -z $(find $file -mmin -$timeout -ls) ]]; do
  sleep $oneMinute
done

echo "Watchdog file($file) has not been updated within $timeout minutes - Rebooting"

curl -X POST --header "Content-Type:application/json" \
    "$RESIN_SUPERVISOR_ADDRESS/v1/reboot?apikey=$RESIN_SUPERVISOR_API_KEY"

