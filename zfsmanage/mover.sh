#!/bin/sh
usage() {
cat << HOOOEY

Shared with no implied warranty or suitability for purpose; this will probably lose data.

# aeria zfs mover 
# ash@aeria.net
# 
# ./mover.sh barrel/tmp          toohey.aeria.lab  z/repli/reaver/tmp        reaver-tmp_to_toohey_flow
#            (local file system) (remote host)     (remote file system)      (flowtag)
#
# reference: https://www.slideshare.net/MatthewAhrens/openzfs-send-and-receive

zfs  restartable delta sigma replication 

Each replication relationship is described by a four tulple which are the required argements that define a replication flow
	1) lfs: local file system source , must be a zfs dataset  eg: tank/usr/home
	2) rhost: remote host replication taret running rsh compatible transport   eg:tardis.co.uk
	3) rfs: remote file system  target must be an existant dataset.  eg: dozer/repltarget/tank_usr_home
	4) flowtag: a string that describes the flow  eg: ash-home-lab_to_tardis_transatlantic_flow


Initally the mover will transmit a bulk snapshot to prime later instances of incremntal sends.
Snapshots are created and destroyed autmatically and retained only slightly longer than needed. 
The mover is restartable; zfs resume tokens are queried for restarts; no extra configuration is required. 
Each flow is rentrant safe.  Feel free to schedule it in a tight loop or  from cron.  

Not BUGS exactly:
Recursion is not suported. 
This script must manage all the snapshots on both zfs  datsets. External removal of snapshots is discouraged.  
Snapshots retained longer than strictly required because paranoia abounds. 
Flowtag is used as part of a regex on remote zfs list operations to identify snapshots that belog to this replication context. 
If a flowtag is a superstring of another, behaviour is undefined. 
No user properites, throttling, rebuffering, readonly status or holds are managed. 

FIXME:
Needs more argument checks; always more. Invarients. Paranioa. 
Push is not always nice; Needs a pull mode to run in a 'bunker' where network access is asymmetric due to nat. 
Bulk transport mode; get ssh and perpaps userland out of the way. Perform 3rd party orchestration remotely away from the push host. 
HOOOEY

}
if [ $# -ne 4 ]; then 
	usage 
	exit  0
fi


#local dataset to send
lfs=${1}
#remote host to receive
rhost=${2}
#remote zfs dataset
rfs=${3} 
#tracking tag which we use to brand snapshots for our exclusive use to 
#please use a decriptive name that describes the replication relationship
mytag=${4} 
thedate=`date +"%s"`

send_verbose_arg="    "
send_verbose_arg=" -v "

# I advocate any rsh compatible pipe transpport,  ssh is ok I guess; netcat transport orchestration would be better 
rsh=" ssh  "  
#gild the ssh opts
#rsh=" $rsh -o CompressionLevel=9  -o Compression=yes"  
rsh=" $rsh -o ConnectionAttempts=5 "  
#rsh=" $rsh -o ForwardX11=no -o LogLevel=INFO "  
#rsh=" $rsh -v  "  

echo "the time is now: ${thedate}. we are sending $lfs.$mytag to $rhost:$rfs "


lockfile_cleanup() {
	rm $mover_lockfile $remote_flow_snapnumbers_file $local_flow_snapnumbers_file || echo "can't kill lockfile"
}

catch_trap() {
	echo "caught trap pid $$  $* for $mytag -  cleaning up locks and dying"
	lockfile_cleanup
	exit -99
}
child_trap (){
	if [ $? -ne 0 ]; then 
		# trap context elides some of the normal shell context
		echo "got abnormal exit code $? from $! $*"
		catch_trap
	else
		echo -n "."
	fi 
}

mover_lockfile=`mktemp /tmp/.mover-$mytag.lockXXX` ||  exit -4
remote_flow_snapnumbers_file=`mktemp /tmp/.mover$mytag-rfs.XXX` || exit -5
local_flow_snapnumbers_file=`mktemp /tmp/.mover$mytag-lfs.XXX` || exit -6

echo tracking remote flow in $remote_flow_snapnumbers_file, local flow  in $local_flow_snapnumbers_file

trap catch_trap TERM INT KILL BUS FPE 2 CHLD
trap child_trap CHLD

snapshot_now () {
	#XX parameterise and armour
	##xxx we might not shoot a snap untill unless there are no snaps to send or 
	# resumable replication can proceed
	nowsnapname="${lfs}@$mytag.${thedate}"
	zfs snapshot $nowsnapname || exit -10
	#update the local snapshot flow catalog
	get_lfs_snaps
}


get_rfs_snaps () {
	# parameters @$rfs , $mytag
	# side effect updates rfscount
	echo remote snapshots in flow:
	$rsh $rhost "zfs list -Hr  -t all -o name ${rfs}" | grep $mytag | cut -f2 -d@ >  $remote_flow_snapnumbers_file
	cat $remote_flow_snapnumbers_file
	rfscount=`wc -l $remote_flow_snapnumbers_file | cut -b1-8`
}

get_rfs_resume_token (){
	in_host=$1
	in_remote_dataset=$2
	resume_token=`$rsh $in_host "zfs get -H -o value receive_resume_token $in_remote_dataset"`
	echo resume token from $in_host:$in_remote_dataset = $resume_token
}

get_lfs_snaps() {
	echo local snapshots:
	zfs list -Hr -t all -o name  ${lfs}  | grep $mytag |  cut -f2 -d@ > $local_flow_snapnumbers_file
	cat $local_flow_snapnumbers_file
}

get_lfs_snaps
get_rfs_snaps 

if [ $rfscount -eq 0 ]; then
	echo "no remote snapshots found for $rhost: $rfs full  initial bulk tx from $lfs@$nowsnapname to $rfs "
	echo "checking for existing token $resume_token"  
	get_rfs_resume_token  $rhost $rfs	
	##XXXXresume_token=`$rsh $rhost "zfs get -H -o value receive_resume_token $rfs"`
	if [ ${#resume_token} -le 30 ]; then 
		arg_resume_token=""
		echo "no token found we shall need a new initial transmit snapshot"
		snapshot_now
		## side effecct generates $nowsnapname
		zfs send $send_verbose_arg ${nowsnapname}  | $rsh $rhost "$zfs_recv_buffer zfs recv -sF $rfs"
	else # resume token processing
		arg_resume_token="-t $resume_token"
		#zfs send $send_verbose_arg $arg_resume_token  | zstreamdump
		#exit 1
		#we don't use nowsnap; but rather the old snapshot; which we really hope is around because 
		# we have no idea about it's name apriori from the token data
		# so please never delete our flowtag snaphots unless you are willing to give up replication
		zfs send $send_verbose_arg $arg_resume_token    | $rsh $rhost " $zfs_recv_buffer zfs recv  -sF $rfs"
	fi 
else 
	echo remote snapshots exist
fi #no remote snapshots 

echo generating fresh catch up  snapshot to operate on
snapshot_now

if  [ $rfscount -eq 0 ]; then 
	#if we got here and have no remote snapshots 
	#something is stale after an initial bulk action  
	# check the remote end for news.
	echo refresh remote snapshots after bulk action 
	get_rfs_snaps
fi 

echo "joining local and remote snaps"
join $local_flow_snapnumbers_file $remote_flow_snapnumbers_file

echo  -n "last common snapshot in flow:"
lastcommon=`join $local_flow_snapnumbers_file $remote_flow_snapnumbers_file | tail -1`
echo $lastcommon


expire_local() {
	echo -n "expire local versions before $frs $lastcommon"
	ln=`grep -n  "$lastcommon" $local_flow_snapnumbers_file | cut -d: -f1`
	ln=$(($ln - 1))
	echo line $ln is the event horizon
	if [ $ln -eq 0 ]; then
		echo not enough snapshots not found,  
		echo should be at least two snaps in the mag always, mabe unless restartability is working
	fi
	head -$ln $local_flow_snapnumbers_file
	########################## delete  old local  versions
	if [ $ln >  6 ]; then
		# destroy them 4 a time; to avoid buildup
		# XX not clear if we ever need to kill 2 because we have restartable trasmits. 
		for i in `head -$ln $local_flow_snapnumbers_file | head -4  `; do
			echo "  $lfs@$i"
			# -d is a defferable destroy to avoid stalling replication 
			zfs destroy -d $lfs@$i
		done
	fi
}


expire_remote () {
	echo  expire needs $rfs, $lastcommon 
	###########################delete old remote versions
	rln=`grep -n  "$lastcommon" $remote_flow_snapnumbers_file | cut -d: -f1`
	rln=$(($rln - 1))
	echo "old remote versions:"
	if [ $rln >  6 ]; then
		for  i in `head -$rln $remote_flow_snapnumbers_file | head -4  `; do
			echo "   "$rfs@$i
			# -d is a defferable destroy to avoid stalling replication 
			$rsh $rhost "zfs destroy  -d $rfs@$i"
		done
	fi
}

echo "newer local versions after $lastcommon"
len=`wc -l $local_flow_snapnumbers_file | cut -b1-8`
ln=$(($len - $ln  -1 ))
tail -$ln $local_flow_snapnumbers_file


latestlocal=`tail -1 $local_flow_snapnumbers_file`
echo " tx with common baselimne:  $lfs@$lastcommon with delta $lfs@$latestlocal" 
get_rfs_resume_token $rhost $rfs
if [ ${#resume_token} -le 30 ]; then 
	echo incremental proceeding
	zfs send  $send_verbose_arg -i  $lfs@$lastcommon $lfs@$latestlocal  |  $rsh $rhost "$zfs_recv_buffer zfs recv -sF $rfs"
else
	echo resume proceeding
	arg_resume_token="-t $resume_token"
	#incremental zfs send -i  $lfs@$lastcommon $lfs@$latestlocal |sh  $rhost "zfs recv -sF $rfs"
	#bulk with token revivifivcaiotn zfs send $send_verbose_arg $arg_resume_token  | $rsh $rhost "zfs recv -sF $rfs"
	#blend the strengths!
	zfs send $send_verbose_arg $arg_resume_token |  $rsh $rhost "$zfs_recv_buffer zfs recv -sF $rfs"
fi
expire_remote 
expire_local
lockfile_cleanup
logger "replication done ${lfs} to ${rhost}:$rfs@$nowsnapname for flow $mytag"

