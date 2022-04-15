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

mover.sh: zfs  restartable delta sigma replication 

Each replication relationship is described by a four tulple which are the required argements that define a replication flow
	1) lfs: local file system source , must be a zfs dataset  eg: tank/usr/home
	2) rhost: remote host replication taret running rsh compatible transport   eg:tardis.co.uk
	3) rfs: remote file system  target must be an existant dataset.  eg: dozer/repltarget/tank_usr_home
	4) flowtag: a string that describes the flow  eg: ash-home-lab_to_tardis_transatlantic_flow

Initally the mover will transmit a bulk snapshot to prime later instances of incremntal sends.
Snapshots are created and destroyed autmatically and retained only slightly longer than needed. 
The mover is restartable; zfs resume tokens are queried for restarts; no extra configuration is required. 
Each flow is rentrant safe.  Feel free to schedule it in a tight loop or  from cron, this scrtipt is 
idempotent.    

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

ENVIRONMENT VARS:
	MOVER_VERBOSE: set 1 to be chatty about internals
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
if [ "${#MOVER_VERBOSE}" -gt 0 ]; then
	send_verbose_arg=" -v "
fi

# I advocate any rsh compatible pipe transpport,  ssh is ok I guess; netcat transport orchestration would be better 
rsh=" ssh  "  
#gild the ssh opts
#rsh=" $rsh -o CompressionLevel=9  -o Compression=yes"  
rsh=" $rsh -o ConnectionAttempts=5 "  
#rsh=" $rsh -o ForwardX11=no -o LogLevel=INFO "  
#rsh=" $rsh -v  "  

echo "the time is now: ${thedate}. we are sending $lfs@${mytag}.EPOCH to $rhost:$rfs "

lockfile_cleanup() {
	vecho "cleaning up tmpfiles"
	vcat  $mover_lockfile 
	vecho  remote snaps
	vcat $remote_flow_snapnumbers_file 
	vecho local snaps
	vcat $local_flow_snapnumbers_file
	#XXXXrm $mover_lockfile $remote_flow_snapnumbers_file $local_flow_snapnumbers_file || echo "can't kill lockfile"
}
catch_trap() {
	eerr=$?
	ecmd=$!
	echo "caught trap $eerr pid $$ $* cmd $ecmd $mytag -  cleaning up locks and dying"
	lockfile_cleanup
	exit 99
}
child_trap (){
	eerr=$?
	ecmd=$!
	if [ $eerr -ne 0 ]; then 
		# trap context elides some of the normal shell context
		echo "got abnormal exit code $eerr from $ecmd $*"
		catch_trap
	else
		#generate a blinking . as childred exit
		echo -n  "."
		printf '\b'
	fi 
}
set_traps() {
	trap catch_trap TERM INT KILL BUS FPE 2 CHLD
	trap child_trap CHLD
	}
unset_traps() {
	trap - 
	trap - TERM INT KILL BUS FPE 2 CHLD
	trap - CHLD
	}

vecho() {
	#if [ "${#MOVER_VERBOSE}" -gt 0 ]; then
	#	echo $*
	#fi
}
vcat() {
	if [ "${#MOVER_VERBOSE}" -gt 0 ]; then
		cat $*
	fi
}
vtail () {
	if [ "${#MOVER_VERBOSE}" -gt 0 ]; then
		tail $*
	fi
}
vjoin () {
	if [ "${#MOVER_VERBOSE}" -gt 0 ]; then
		join $*
	fi
}

vecho  being verbose
mover_lockfile=`mktemp /tmp/.mover-$mytag.lockXXX` ||  exit -4
remote_flow_snapnumbers_file=`mktemp /tmp/.mover$mytag-rfs.XXX` || exit -5
local_flow_snapnumbers_file=`mktemp /tmp/.mover$mytag-lfs.XXX` || exit -6
#echo tracking remote flow in $remote_flow_snapnumbers_file, local flow  in $local_flow_snapnumbers_file

snapshot_now () {
	#XX parameterise and armour
	##xxx we might not shoot a snap untill unless there are no snaps to send or 
	# resumable replication can proceed
	unset_traps
	nowsnapname="${lfs}@$mytag.${thedate}"
	snap_exists=`zfs list -H -o name $nowsnapname 2> /dev/null`
	set_traps
	if [ -z $snap_exists ]; then
		zfs snapshot $nowsnapname || exit -10
		#update the local snapshot flow catalog
	else
		vecho "${nowsnapname} exists; that's ok"
	fi	
	get_lfs_snaps
}

get_rfs_presence () {
	vecho "checking for existance of ${rfs}"
	rfs_existsts=`$rsh $rhost "zfs list $rfs"`  ## this will bomb
}

get_rfs_snaps () {
	# parameters @$rfs , $mytag
	# side effect updates rfscount
	vecho remote snapshots in flow:
	$rsh $rhost "zfs list -Hr  -t all -o name ${rfs}" | grep $mytag | cut -f2 -d@ >  $remote_flow_snapnumbers_file
	vcat $remote_flow_snapnumbers_file
	rfscount=`wc -l $remote_flow_snapnumbers_file | cut -b1-8`
	if [ $rfscount -eq 0 ]; then 
		vecho no remote snapshots. 
	fi
}

get_rfs_resume_token (){
	in_host=$1
	in_remote_dataset=$2
	resume_token=`$rsh $in_host "zfs get -H -o value receive_resume_token $in_remote_dataset"`
	if [ ${#resume_token} -le 30 ]; then 
		#the resume token is '-' when not populatet; filter it to ""
		resume_token="" 
	else 
		echo resume token from $in_host:$in_remote_dataset = $resume_token
	fi
}

get_lfs_snaps() {
	vecho local snapshots:
	zfs list -Hr -t all -o name  ${lfs}  | grep $mytag |  cut -f2 -d@ > $local_flow_snapnumbers_file
	vcat $local_flow_snapnumbers_file
}

set_traps
get_lfs_snaps
get_rfs_presence
get_rfs_snaps 

if [ $rfscount -eq 0 ]; then
	echo "no remote snapshots found for $rhost: $rfs full  initial bulk tx from $lfs@$nowsnapname to $rfs "
	get_rfs_resume_token  $rhost $rfs	
	vecho "checking for existing token $resume_token"  
	if [ ${#resume_token} -le 30 ]; then 
		arg_resume_token=""
		echo "no token found. we shall need a new initial transmit snapshot"
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
	vecho remote snapshots exist. attempting incremental
fi #no remote snapshots 

vecho generating fresh catch up snapshot to operate on, we run the catch up  incase the inital bulk tx takes forever
snapshot_now

if  [ $rfscount -eq 0 ]; then 
	#if we got here and have no remote snapshots 
	#something is stale after an initial bulk action  
	# check the remote end for news.
	vecho refresh remote snapshots after bulk action 
	get_rfs_snaps
fi 

vecho "joining local and remote snaps"
vjoin $local_flow_snapnumbers_file $remote_flow_snapnumbers_file

echo  -n "last common snapshot in flow:"
lastcommon=`join $local_flow_snapnumbers_file $remote_flow_snapnumbers_file | tail -1`
if [ -z $lastcommon ]; then 
	echo " there is no common last snapshot; local snapshots may have been deleted by someone else!"
	echo " remove remote dataset :${rfs}  and rerun me"
	exit 67
fi
echo $lastcommon


expire_local() {
	vecho -n "expire local versions before $rfs $lastcommon"
	ln=`grep -n  "$lastcommon" $local_flow_snapnumbers_file | cut -d: -f1`
	ln=$(($ln - 1))
	#echo line $ln is the event horizon
	if [ $ln -eq 0 ]; then
		vecho not enough snapshots not found,   this is fine.
		vecho should be at least two snaps in the mag always, unless restarting an inital transmit
	fi
	#head -$ln $local_flow_snapnumbers_file
	#delete  old local  versions
	if [ $ln -gt  4 ]; then
		# destroy them batch at a time; to avoid buildup
		for i in `head -$ln $local_flow_snapnumbers_file | head -16  `; do
			vecho " destroying  local obsolete snaps  $lfs@$i"
			# -d is a defferable destroy to avoid stalling replication 
			zfs destroy -d $lfs@$i
		done
	fi
}


expire_remote () {
	vecho  expire snaps older than $rfs, $lastcommon 
	#delete old remote versions
	rln=`grep -n "$lastcommon" $remote_flow_snapnumbers_file | cut -d: -f1`
	rln=$(($rln - 1))
	vecho " destroying obsolete remote versions:"
	if [ $rln -gt 4 ]; then
		for  i in `head -$rln $remote_flow_snapnumbers_file | head -16  `; do
			vecho    ${rfs}  ${i}
			# -d is a defferable destroy to avoid stalling replication 
			$rsh $rhost "zfs destroy  -d $rfs@$i"
		done
	fi
}

vecho "newer local versions after $lastcommon"
len=`wc -l $local_flow_snapnumbers_file | cut -b1-8`
ln=$(($len - $ln  -1 ))
vtail -$ln $local_flow_snapnumbers_file


latestlocal=`tail -1 $local_flow_snapnumbers_file`
echo " tx delta  from  $lfs@$lastcommon ->  @$latestlocal" 
get_rfs_resume_token $rhost $rfs
if [ ${#resume_token} -le 30 ]; then 
	vecho incremental proceeding
	zfs send  $send_verbose_arg -i  $lfs@$lastcommon $lfs@$latestlocal  |  $rsh $rhost "$zfs_recv_buffer zfs recv -sF $rfs"
else
	echo resume proceeding with token  ${resume_token}
	arg_resume_token="-t $resume_token"
	#bulk with token revivifivcaiotn zfs send $send_verbose_arg $arg_resume_token  | $rsh $rhost "zfs recv -sF $rfs"
	#blend the strengths!
	zfs send $send_verbose_arg $arg_resume_token |  $rsh $rhost "$zfs_recv_buffer zfs recv -sF $rfs"
fi
expire_remote 
expire_local
lockfile_cleanup
logger "replication done ${lfs} to ${rhost}:$rfs@$nowsnapname for flow $mytag"

