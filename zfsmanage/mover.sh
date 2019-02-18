#!/bin/sh
usage() {
cat << HOOOEY

Shared with no implied warranty or suitability for purpose. This will probably lose your data, eat your snacks and run away with your dog.

# aeria zfs mover 
# ash@aeria.net
# 
# ./mover.sh  txuser@kaylee.a.aeria.net:dozer/var   rxuser@mal.a.aeria.net:trinity/dozer-target  
# ./mover.sh  txuser@kaylee.a.aeria.net:dozer/var   rxuser@mal.a.aeria.net:trinity/dozer-target  
#             (transmithost):(source file system)   (receive host):(destination file system)
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
if [ $# -lt 2 ]; then 
	usage 
	exit  0
fi


txspec=${1}
rxspec=${2}
start_unixtime=`date +"%s"`

send_verbose_arg="    "
send_verbose_arg=" -v "

## XX use ipqos, nopasswd,  controlpersist
ssh_patience="5"
rsh=" ssh -o ConnectTimeout=$ssh_patience  -o ControlMaster=yes -o ControlPersist=yes"  

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
#XXX these have to be configurable

flowtag_prefix=`echo "$tx_host:$tx_fs-_-$rx_host:$rx_fs" | tr '/' '-'`

#this will be the best port number we can pull out of a hat!
#and possibly the a conflicted one
vm_portnum=$((64000 - ( `od /dev/random | head -1 | cut -f3 -w` % 4000 ) )) 
tx_pipe="viamillipede tx $rx_host $vm_portnum verbose 5"
rx_pipe="viamillipede rx $vm_portnum verbose 5"


#use $transport to get a pipe from host tx_host to host rx_host
#construct the agents to live on the destination
#install them and start them to run in the background
orchestrate_rxtx() { 

	#ratscript remote agents that persist while the transfer is runnning
	txratscript=`mktemp /tmp/moverproto-tx$flowtag_prefix.XXX`
	rxratscript=`mktemp /tmp/moverproto-rx$flowtag_prefix.XXX`

	echo " #!/bin/sh -x " > $txratscript
	echo " $zfs_send_operation | $tx_pipe >> /tmp/txratout 2>&1 & " >> $txratscript

	echo " #!/bin/sh -x " > $rxratscript
	echo "$rx_pipe | $zfs_recv_operation >> /tmp/rxratout  2>&1 &" >> $rxratscript
	#XXX should delete the rat after success?

	#install the ratscripts
	remote_txratscript=`$rsh $tx_user_name@$tx_host "mktemp  /tmp/moverrat-tx$flowtag_prefix.XXX"`
	remote_rxratscript=`$rsh $rx_user_name@$rx_host "mktemp  /tmp/moverrat-rx$flowtag_prefix.XXX"`
	scp $txratscript  $tx_user_name@$tx_host:$remote_txratscript
	scp $rxratscript  $rx_user_name@$rx_host:$remote_rxratscript
	
	#launch the rx, then the tx scripts
	#ignore detaches
	$rsh -n $rx_user_name@$rx_host "sh $remote_rxratscript &" &
	$rsh -n $tx_user_name@$tx_host "sh $remote_txratscript &" &
	echo "awaiting  dispatched jobs"
	exit 0 
}


lockfile_cleanup() {
	rm $mover_lockfile $rx_flow_snapnumbers_file $tx_flow_snapnumbers_file || echo "can't remove lockfile"
}

catch_trap() {
	echo "caught trap pid $$  $* for $mytag -  cleaning up locks and dying"
	
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
	$rsh ${rx_user_name}@${rx_host} "zfs list -Hr -t snapshot -o name ${rx_fs} | grep ${rx_fs}@${flowtag_prefix} | cut -s -f2 -d@ || echo -n ''  " >  $rx_flow_snapnumbers_file
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
	$rsh $tx_user_name@$tx_host "zfs list -Hr -t snapshot -o name ${tx_fs} | grep ${tx_fs}@${flowtag_prefix} |  cut -s -f2 -d@ || echo -n '' " > $tx_flow_snapnumbers_file
	cat $tx_flow_snapnumbers_file
}


get_rx_snaps
get_tx_snaps 

#kill -FPE $$ 

if [ $rx_snap_count -eq 0 ]; then
	echo "no rx snapshots found at $rx_host:$rx_fs. Performing full initial bulk tx from $tx_host:$tx_fs"
	echo "checking for existing token $resume_token during inital bulk stage"  
	get_rx_resume_token 
	if [ ${#resume_token} -le 30 ]; then 
		arg_resume_token=""
		echo "no token found we shall need a new initial transmit snapshot"
		snapshot_now
		## side effect generates $nowsnapname
		zfs_send_operation="zfs send -R $send_verbose_arg ${nowsnapname}"
		zfs_recv_operation="zfs recv  -sF $rx_fs "
		orchestrate_rxtx  	
		echo wating for godot
		exit 0
		#XXXXzfs send $send_verbose_arg ${nowsnapname}  | $rsh $rhost "$zfs_recv_buffer zfs recv -sF $rfs"
	else # resume token processing
		arg_resume_token="-t $resume_token"
		#zfs send $send_verbose_arg $arg_resume_token  | zstreamdump
		#exit 1
		#we don't use nowsnap; but rather the old snapshot; which we really hope is around because 
		# we have no idea about it's name apriori from the token data
		# so please never delete our flowtag snaphots unless you are willing to give up replication
		zfs_send_operation="zfs send $send_verbose_arg $arg_resume_token  "
		zfs_recv_operation="zfs recv  -sF $rx_fs "
		orchestrate_rxtx  	
		echo wating for godot
		exit 0 
		#XXXXXzfs send $send_verbose_arg $arg_resume_token  | $rsh $rhost " $zfs_recv_buffer zfs recv  -sF $rfs"
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
	echo  expire needs $rx_fs, $lastcommon 
	###########################delete old remote versions
	#XXX this is not going to work anymore
	rln=`grep -n  "$lastcommon" $rx_flow_snapnumbers_file | cut -d: -f1`
	rln=$(($rln - 1))
	echo "old remote versions:"
	exit -444
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
echo " tx with common baseline:  $rx_fs@$lastcommon with delta $rx_fs@$latest_tx" 
get_rfs_resume_token $rhost $rfs
if [ ${#resume_token} -le 30 ]; then 
	echo incremental proceeding
	#XXXXXXzfs send  $send_verbose_arg -i  $rx_fs@$lastcommon $rx_fs@$latest_tx  |  $rsh $rhost "$zfs_recv_buffer zfs recv -sF $rfs"
else
	echo resume proceeding
	arg_resume_token="-t $resume_token"
	#incremental zfs send -i  $lfs@$lastcommon $lfs@$latest_tx |sh  $rhost "zfs recv -sF $rfs"
	#bulk with token revivifivcaiotn zfs send $send_verbose_arg $arg_resume_token  | $rsh $rhost "zfs recv -sF $rfs"
	#blend the strengths!
	##XXXXXzfs send $send_verbose_arg $arg_resume_token |  $rsh $rhost "$zfs_recv_buffer zfs recv -sF $rfs"
fi
expire_remote 
expire_local
lockfile_cleanup
logger "replication done ${lfs} to ${rhost}:$rfs@$nowsnapname for flow $mytag"
