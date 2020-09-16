#!/bin/sh -x

logdir="/var/ipmisensorslog"
mkdir -p  $logdir
date=`/bin/date +"%Y%m%d%H%M"`
when=`/bin/date +"%s"`
echo "{epochtime: $when}"  > $logdir/log.$date
/usr/local/sbin/ipmi-sensors >> $logdir/log.$date
