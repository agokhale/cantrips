#!/bin/sh
#badhairday.sh <poolname>
#dumps a collosal amount of forensics about a zpool
sep()
{
	echo -n  =================
	echo $1
	date +"%s"
	sleep 1
}


sep  "two seconds to decide better"
sep "cannonical history"
zpool history -i  $1 
sep "txgs"
zpool history -i | grep txg | sed -E 's/^.*txg:([0-9]*).*$/\1/ '
sep "configutaion via -C"
zdb  -AAA -C -e $1
sep "dataset -d" 
zdb  -AAA -d -e $1
sep "che alernate historty"
zdb  -AAA -v -h -e $1 
sep " -u spacemap"
zdb  -AAA -u -e $1
sep "metaslablication"
zdb -mm -e $1
sep uberblk currently
zdb -u -e $1
sep available ubers 
disks=`ls /dev/*da* | grep p2`
echo $disks
sep uberblocks
for pdev in $disks
do
	echo $pdev -@-_-- 
	zdb -u -l $pdev
done
