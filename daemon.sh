#!/bin/bash

if [ -z "$METERID" ]; then
  echo "METERID not set, launching in debug mode"
  echo "Enter Terminal via Resin and run 'rtlamr -msgtype=r900' to see all the local water meters and find your meter ID"
  rtl_tcp
  exit 0
fi

# Kill this script (and restart the container) if we haven't seen an update in 30 minutes
./watchdog.sh 30 updated.log &

while true; do
  # Suppress the very verbose output of rtl_tcp and background the process
  rtl_tcp &> /dev/null &
  rtl_tcp_pid=$! # Save the pid for murder later
  sleep 10 #Let rtl_tcp startup and open a port

  json=$(rtlamr -msgtype=r900 -filterid=$METERID -single=true -format=json)
  echo "Meter info: $json"

  consumption=$(echo $json | python -c 'import json,sys;obj=json.load(sys.stdin);print float(obj["Message"]["Consumption"])/10000')
  echo "Current consumption: $consumption CCF"

  # Replace with your custom logging code
  if [ ! -z "$STATX_APIKEY" ]; then
    echo "Logging to StatX"
    statx --apikey $STATX_APIKEY --authtoken $STATX_AUTHTOKEN update --group $STATX_GROUPID --stat $STATX_STATID --value $consumption
  fi

  kill $rtl_tcp_pid # rtl_tcp has a memory leak and hangs after frequent use, restarts required - https://github.com/bemasher/rtlamr/issues/49
  sleep 30 # I don't need THAT many updates

  # Let the watchdog know we've done another cycle
  touch updated.log
done

