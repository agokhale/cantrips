#!/bin/sh 
if [ $# -ne 2 ]; then
	echo usage:  bkuperator death /etc zroot
	exit 22; 
fi  
echo ---------------------------------------------------
echo $0 started `date +"%s"` $1 $2

source_host=$1
source_path=$2


# settings and tunables
rsync_flags="--bwlimit=1m -azv  --delete" 
zfs_top_dataset="zz/bk"
#zfs_top_dataset="zz/bkxx" # bad ds for test



#sanity, does the backup pool & ds  exist?
tst=`zfs list $zfs_top_dataset | grep $zfs_top_dataset`
echo destination top dataset: $tst  status:$zfs_top_dataset
if [ -z "$tst" ]; then
	echo error no top bakup dataset:  $zfs_top_dataset
	echo consider finding it, or making it
	exit 1; 
fi

host_dataset=$zfs_top_dataset/$source_host
tst=`zfs list $host_dataset | grep $host_dataset`
if [ -z "$tst" ]; then
	echo warnng: no host dataset:  $host_dataset	, creating in 5s.. 
	sleep 5 
	zfs create $host_dataset
	echo host dataset:  $host_dataset	, created
fi

mkdir -p /$host_dataset/$source_path
date  >> logbyhost/$source_host
vmstat  >> logbyhost/$source_host
uptime  >> logbyhost/$source_host
rsync $rsync_flags $source_host:$source_path/ /$host_dataset/$source_path/  | tee -a logbyhost/$source_host
sleep 3

