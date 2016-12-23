#!/bin/bash

if [ -z "$METERID" ]; then
  echo "METERID not set, launching in debug mode"
  echo "Enter SSH via Resin and run 'rtlamr -msgtype=r900' to see all the local water meters and find your meter ID"
  rtl_tcp
  exit 0
fi

# Suppress the very verbose output of rtl_tcp and background the process
rtl_tcp &> /dev/null &
sleep 5 #Let rtl_tcp startup and open a port

# Kill this script (and restart the container) if we haven't seen an update in 30 minutes
./watchdog.sh $$ 30 updated.log &

while true; do
  json=$(rtlamr -msgtype=r900 -filterid=$METERID -single=true -format=json)
  echo "Meter info: $json"

  consumption=$(echo $json | python -c 'import json,sys;obj=json.load(sys.stdin);print float(obj["Message"]["Consumption"])/10000')
  echo "Current consumption: $consumption CCF"

  # Replace with your custom logging code
  if [ ! -z "$STATX_APIKEY" ]; then
    echo "Logging to StatX"
    statx --apikey $STATX_APIKEY --authtoken $STATX_AUTHTOKEN update --group $STATX_GROUPID --stat $STATX_STATID --value $consumption
  fi

  # Let the watchdog know we've updated recently
  touch updated.log
done

