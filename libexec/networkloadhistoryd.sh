#!/bin/sh 

while true; do
	sleep 1 
	netstat  -i -b  | networkloadhistorypoint.awk -v iface=$1 >> /tmp/networkload.history
done
