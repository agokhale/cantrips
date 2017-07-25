#!/bin/sh

if [ "${1}" = "hourly" ] ; then  
	datefmt=`date +'%H'`
fi
if [ "${1}" = "daily" ] ; then   
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
