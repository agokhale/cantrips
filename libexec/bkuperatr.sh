#!/bin/sh  
set -x
if [ $# -ne 2 ]; then
	echo usage:  bkuperator death /etc
	exit 22; 
fi  
echo ---------------------------------------------------
echo $0 started `date +"%s"` $1 $2

source_host=$1
source_path=$2


# settings and tunables
rsync_flags="--bwlimit=10m  --one-file-system --force-uchange --force-schange -azv  --delete" 

if [ -z "${bkupratr_log}" ]; then
	echo error no  env bkuperatr_log
	exit 1
fi 

zfs_top_dataset=${bkupratr_top_dataset}
if [ -z "$zfs_top_dataset" ]; then
	echo error no  env bkupratr_top_dataset
	exit 1
fi
logbyhost="${bkupratr_log}/${source_host}"



#sanity, does the backup pool & ds  exist?
tst=`zfs list $zfs_top_dataset | grep $zfs_top_dataset`
echo destination top dataset: $tst  status:$zfs_top_dataset
if [ -z "$tst" ]; then
	echo error no top bakup dataset:  $zfs_top_dataset
	echo consider finding it, or making it
	exit 1; 
fi

#does the source exist?
tst=`ssh $source_host "file $source_path"`
if [  "$tst" !=  "$source_path: directory" ]; then
	echo ${source_host}:${source_path}  is a $tst , should be a directory
fi 

host_dataset=$zfs_top_dataset/$source_host
tst=`zfs list $host_dataset | grep $host_dataset`
if [ -z "$tst" ]; then
	echo warnng: no host dataset:  $host_dataset	, creating in 5s.. 
	sleep 5
	zfs create $host_dataset
	echo host dataset:  $host_dataset created
fi


mkdir -p /$host_dataset/$source_path
date  >> $logbyhost
vmstat  >> $logbyhost
uptime  >> $logbyhost
rsync $rsync_flags $source_host:$source_path/ /$host_dataset/$source_path/  | tee -a $logbyhost
sleep 3

