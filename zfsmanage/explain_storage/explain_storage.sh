#!/bin/sh
#set -x

sepline () {
	echo "$1--------------------------------------  $*"
}
tmpd=`mktemp -dt explainstorage`
export tmpd=$tmpd
echo $tmpd >> /tmp/explainstorage.junk
sepline $tmpd
mkdir -p  $tmpd/tempfiles
mkdir -p $tmpd/infiles

glabel status > $tmpd/infiles/glabel.out
gmultipath status >> $tmpd/infiles/glabel.out
sesutil map > $tmpd/infiles/ses.out
zpool status > $tmpd/infiles/zpool.out

do_ses () {
	sepline ses
	echo $tmpd/infiles/ses.out
	cat $tmpd/infiles/ses.out | ./normalize_ses.nawk | tee $tmpd/tempfiles/ses.normal 
	wc -l $tmpd/tempfiles/ses.normal
}
do_ses

do_pools () {
	sepline pools
	echo $tmpd/infiles/zpool.out
	cat $tmpd/infiles/zpool.out | ./normalize_pool.nawk | tee $tmpd/tempfiles/pool.normal
	wc -l $tmpd/tempfiles/pool.normal
	sepline joinedpools
	cat $tmpd/tempfiles/pool.normal | ./join_pool.nawk | tee $tmpd/pool.out
	wc -l $tmpd/pool.out
}
do_pools

do_smart () {
	sepline smart
	disks=$( geom disk status | sed -E 's/^ +//' |  cut -w -f1; cd /dev/ ; ls nvme* )
	for dev in $disks; do
		echo -n "."
		printf "\b" 
		echo  "xpln-start-of /dev/$dev  " >> $tmpd/smart.raw
		smartctl -a /dev/$dev  >> $tmpd/smart.raw
		printf "\b" 
		echo  "xpln-end-of /dev/$dev  " >> $tmpd/smart.raw
	done
	echo "smart  collection done"
	echo $tmpd/smart.raw
	cat $tmpd/smart.raw | ./normalize_smart.nawk   | tee  $tmpd/smart.out
	wc -l $tmpd/smart.out
}
do_smart

## now create a reverse map from disks, mpaths back to pools
# this will show unused disks
sepline "mpath"
gmultipath status | ./normalize_mpath.nawk >  $tmpd/mpath.normal
wc -l $tmpd/mpath.normal

sepline "all_disk_assignments"
geom disk status | awk '!/Name/ {print($1);}'   >  $tmpd/geom.list
wc -l $tmpd/geom.list

for gt in `cat $tmpd/geom.list`; do
	#  mp:multipath/jhk26r      disk:da23  => multipath/jk...
	mpath=` ./selectawk.nawk -v grepkill="$gt\$" -v select="mp:" <  $tmpd/mpath.normal `
	if [ $mpath"__" != "__" ]; then 
		pool=` ./selectawk.nawk -v grepkill="$mpath" -v select="pool:" <  $tmpd/pool.out`
	else
		pool=` ./selectawk.nawk -v grepkill="$gt" -v select="pool:" <  $tmpd/pool.out`
	fi;

	echo -n "disk:$gt"   | tee -a $tmpd/disks.out
	if [ "$mpath"__ != "__" ]; then 
		echo -n " mpath:$mpath "| tee -a $tmpd/disks.out
	fi
	if [ $pool"__" != "__" ]; then 
		echo -n  " pool:$pool"| tee -a $tmpd/disks.out
	fi
	echo " " | tee -a $tmpd/disks.out
	mpath=""; pool=""; pool2="";
done
wc -l $tmpd/disks.out

ls $tmpd
echo $tmpd 
