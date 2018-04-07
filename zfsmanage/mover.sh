#!/bin/sh
usage() {
cat << HOOOEY

Shared with no implied warranty or suitability for purpose. This will probably lose your data, eat your snacks and run away with your dog.

# aeria zfs mover 
# ash@aeria.net
# 
# ./mover.sh  txuser@kaylee.a.aeria.net:dozer/var   pipe           rxuser@mal.a.aeria.net:trinity/dozer-target  
# ./mover.sh  txuser@kaylee.a.aeria.net:dozer/var   ssh            rxuser@mal.a.aeria.net:trinity/dozer-target  
#             (transmithost):(source file system)   (transport)    (receive host):(destination file system)
#
# reference: https://www.slideshare.net/MatthewAhrens/openzfs-send-and-receive
# ealier version: https://github.com/agokhale/cantrips/blob/d3df2e2468427aaf6f607cbd0fa493af5f4e7ad0/zfsmanage/mover.sh

zfs replication resumeable, resiliant

Initally the mover will transmit a bulk snapshot to prime later instances of incremntal sends.
Snapshots are created and destroyed autmatically and retained.
The mover is restartable; zfs resume tokens are queried for resumable replication.
Each flow is rentrant safe.  Feel free to schedule it in a tight loop or from cron.  

HOOOEY
}
if [ $# -lt 3 ]; then 
	usage 
	exit  0
fi


txspec=${1}
transport=${2}
rxspec=${3}
start_unixtime=`date +"%s"`

send_verbose_arg="    "
send_verbose_arg=" -v "

## XX use ipqos, nopasswd,  controlpersist
ssh_patience="5"
rsh=" ssh -o ConnectTimeout=$ssh_patience "  

# input:  $1 is txuser@kaylee.a.aeria.net:dozer/va
# output: ousername,ohostname,ofspart
parse_spec() { 
	if [ $# -ne 1 ]; then
		echo arg count incorrect
		exit
	fi
	ohostspecpart=` echo $1 | cut -s -f1 -d:`	
	hasatsign=`echo $ohostspecpart   | grep '@' `
	if [ "$hasatsign" ];  then
		ousername=`echo $ohostspecpart | cut -f1 -d@`
		ohostname=`echo $ohostspecpart | cut -f2 -d@`
	else
		ousername="root"
		ohostname=$ohostspecpart

	fi
	ofspart=` echo $1 | cut -s -f2 -d:`	
	if [ "$ofspart" ]; then
	else
		echo nofspart
		exit -3
	fi
	if [ "$ohostname" ]; then
	else
		echo nohostname
		exit -3
	fi
}

check_access_from_spec(){
	tstart=`date +"%s"`
	remote_type=`$rsh $ousername@$ohostname "zfs get -H type $ofspart" `
	tend=`date +"%s"`
	echo "$ohostname took $(( $tend - tstart ))s to query $ofspart returned:'$remote_type'"
	if [ ${#remote_type} -ge 1 ];  then
	else 
		echo "can't query dataset  $rsh $ousername@$ohostname 'zfs get -H type $ofspart' "
		exit -123
	fi

}

parse_spec  $txspec
check_access_from_spec
tx_user_name=$ousername
tx_host=$ohostname
tx_fs=$ofspart

parse_spec  $rxspec
check_access_from_spec
rx_user_name=$ousername
rx_host=$ohostname
rx_fs=$ofspart


# synthetic flow name will make the relationship clear and provide unique snapshot names
# allowable snapshot names: 
# the old approach may have confused ppl 
# https://docs.oracle.com/cd/E26505_01/html/E37384/gbcpt.html
flowtag_prefix=`echo "$tx_host:$tx_fs-_-$rx_host:$rx_fs" | tr '/' '-'`
echo $flowtag_prefix


lockfile_cleanup() {
	rm $mover_lockfile $rx_flow_snapnumbers_file $tx_flow_snapnumbers_file || echo "can't remove lockfile"
}

catch_trap() {
	echo "caught trap pid $$  $* for $mytag -  cleaning up locks and dying"
	lockfile_cleanup
	exit -99
}
child_trap() {
	if [ $? -ne 0 ]; then 
		# trap context elides some of the normal shell context
		echo "got abnormal exit code $? from $! $*"
		catch_trap
	else
		echo -n "."
	fi 
}

mover_lockfile=`mktemp /tmp/.mover-$flowtag_prefix.lockXXX` ||  exit -4
rx_flow_snapnumbers_file=`mktemp /tmp/.mover$flowtag_prefix-rxfs.XXX` || exit -5
tx_flow_snapnumbers_file=`mktemp /tmp/.mover$flowtag_prefix-txfs.XXX` || exit -6

echo tracking remote flow in $rx_flow_snapnumbers_file, local flow  in $tx_flow_snapnumbers_file

trap catch_trap TERM INT KILL BUS FPE 2 CHLD
trap child_trap CHLD

# create a snapshot on the tx host that falls within the flow
snapshot_now() {
	nowsnapname="${tx_fs}@${flowtag_prefix}.${start_unixtime}"
	$rsh $tx_user_name@$tx_host "zfs snapshot -r $nowsnapname " || exit -111
	## XXX lock the snapshot https://docs.oracle.com/cd/E19253-01/819-5461/gjdfk/index.html
	$rsh $tx_user_name@$tx_host "zfs hold -r $flowtag_prefix $nowsnapname " || exit -112
	#update the local snapshot flow catalog
	get_tx_snaps
}

get_rx_snaps() {
	# parameters @$rfs , $flowtag_prefix
	# an exist snap indicates that the replication can continue via incremental ( Not resumable! ) replication.
	# side effect updates rx_snap_count
	echo rx snapshots in flow:
	$rsh $rx_user_name@$rx_host "zfs list -Hr -t snapshot -o name ${rx_fs} | grep ${rx_fs}@${flowtag_prefix} | cut -s -f2 -d@ " >  $rx_flow_snapnumbers_file
	cat $rx_flow_snapnumbers_file
	rx_snap_count=`wc -l $rx_flow_snapnumbers_file | cut -s -f2 -w`
}

get_rx_resume_token() {
	resume_token=`$rsh $rx_user_name@$rx_host "zfs get -H -o value receive_resume_token $rx_fs"`
	if [ $resume_token ]; then 
		echo "resume token from $rx_user_name@$rx_host:$rx_fs = $resume_token"
	else
	fi 
}

get_tx_snaps() {
	echo tx snapshots:
	$rsh $tx_user_name@$tx_host "zfs list -Hr -t snapshot -o name ${lfs} | grep ${rx_fs}@${flowtag_prefix} |  cut -f2 -d@ " > $tx_flow_snapnumbers_file
	cat $tx_flow_snapnumbers_file
}


get_rx_snaps
get_tx_snaps 

#kill -FPE $$ 
exit -1

if [ $rfscount -eq 0 ]; then
	echo "no remote snapshots found for $rhost: $rfs full initial bulk tx from $lfs@$nowsnapname to $rfs "
	echo "checking for existing token $resume_token"  
	get_rfs_resume_token 
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
join $tx_flow_snapnumbers_file $rx_flow_snapnumbers_file

echo  -n "last common snapshot in flow:"
lastcommon=`join $tx_flow_snapnumbers_file $rx_flow_snapnumbers_file | tail -1`
echo $lastcommon


expire_local() {
	echo -n "expire local versions before $frs $lastcommon"
	ln=`grep -n  "$lastcommon" $tx_flow_snapnumbers_file | cut -d: -f1`
	ln=$(($ln - 1))
	echo line $ln is the event horizon
	if [ $ln -eq 0 ]; then
		echo not enough snapshots not found,  
		echo should be at least two snaps in the mag always, mabe unless restartability is working
	fi
	head -$ln $tx_flow_snapnumbers_file
	########################## delete  old local  versions
	if [ $ln >  6 ]; then
		# destroy them 4 a time; to avoid buildup
		# XX not clear if we ever need to kill 2 because we have restartable trasmits. 
		for i in `head -$ln $tx_flow_snapnumbers_file | head -4  `; do
			echo "  $lfs@$i"
			# -d is a defferable destroy to avoid stalling replication 
			zfs destroy -d $lfs@$i
		done
	fi
}


expire_remote () {
	echo  expire needs $rfs, $lastcommon 
	###########################delete old remote versions
	rln=`grep -n  "$lastcommon" $rx_flow_snapnumbers_file | cut -d: -f1`
	rln=$(($rln - 1))
	echo "old remote versions:"
	if [ $rln >  6 ]; then
		for  i in `head -$rln $rx_flow_snapnumbers_file | head -4  `; do
			echo "   "$rfs@$i
			# -d is a defferable destroy to avoid stalling replication 
			$rsh $rhost "zfs destroy  -d $rfs@$i"
		done
	fi
}

echo "newer local versions after $lastcommon"
len=`wc -l $tx_flow_snapnumbers_file | cut -b1-8`
ln=$(($len - $ln  -1 ))
tail -$ln $tx_flow_snapnumbers_file


latest_tx=`tail -1 $tx_flow_snapnumbers_file`
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
