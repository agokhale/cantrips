#!/bin/sh
# too simple to be right
if [ "${1}" = "hourly" ] ; then  
	datefmt=`date +'%H'`
fi
if [ "${1}" = "daily" ] ; then   
#this is very broken for daily snapshots on  day of month > 29 :/
	datefmt=`date +'%d'`
fi
if [ "${1}" = "weekly" ] ; then  
	datefmt=`date +'%m%d'`
fi

# snap.sh  weekly z/aeriahome
snapname="${2}@${1}.${datefmt}"
zfs destroy -f  $snapname 
zfs snapshot $snapname
logger "snapshot performed for $snapname"
