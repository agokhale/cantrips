#!/bin/sh 

while true; do
	sleep 1 
	netstat  -i -b  | networkloadhistorypoint.awk  >> /tmp/networkload.history
done
