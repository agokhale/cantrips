#!/bin/sh  -ex

#usage: time_to_gw_ping.sh || echo "do this when slow: service netif restart" 

#libxo  is territbly worse than this:
#netstat -rn --libxo json | jq '.[]."route-information".["route-table"].["rt-family"].[].[] '
#so get the default route the lousy way 

gw_ip=`netstat -rn | grep default | cut -w -f2`

#PING gw (192.168.1.1): 56 data bytes
#64 bytes from 192.168.1.1: icmp_seq=0 ttl=64 time=1.613 ms
#                                             f7^^^ =  f2=^^^^

t_sec=` ping -c 1 $gw_ip | grep time | cut -w -f7 | cut -d= -f2 `

echo $t_sec 

#9ms is a looong  time for lan to gw 
awk  -v tsec=$t_sec 'BEGIN { if (tsec > 119.0 ){exit(-2);} } ' 
