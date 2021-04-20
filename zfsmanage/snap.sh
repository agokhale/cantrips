#!/bin/sh
# too simple to be right
#20 6 * * 0   ${HOME}/bin/snap.sh weekly barrel/tmp
#20 5 * * *   ${HOME}/bin/snap.sh daily barrel/tmp
#29 * * * *   ${HOME}/bin/snap.sh hourly barrel/tmp
#* * * * *   ${HOME}/bin/mover.sh barrel/tmp toohey z/reaver/btmp reaverbtmpflo > /dev/null
#* * * * *   ${HOME}/bin/mover.sh barrel/tmp toohey z/reaver/btmp reaverbtmpflo > /dev/null

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
