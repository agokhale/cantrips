#!/bin/sh -x
verb=${1:-4}
user='xpi'
host='delerium'
port=12322
targets="tx delerium $port tx 192.168.239.250 $port"
threads=" threads 14"
#host='localhost'
rsh="ssh $user@$host "
sample="rand4.payload"


zstreamref () {
	ds="dozer/bbone@c"
	target_ds="zz/sampletarget"
	user="root"
	rsh="ssh $user@$host "
	$rsh  " zfs destroy -r  $target_ds"
	#zfs send dozer/bbone@c | dd bs=8k | ssh root@delerium "zfs recv zz/bbt
	zfs send $ds  | dd bs=8k | $rsh "zfs recv $target_ds" 
}

zstreamremote () {
	ds="dozer/bbone@c"
	target_ds="zz/sampletarget"
	user="root"
	rsh="ssh $user@$host "
	
	$rsh "pkill viamillipede-sample "  
	pkill viamillipede
	$rsh  " zfs destroy -r  $target_ds"
	cat viamillipede |  $rsh "cat - > /tmp/viamillipede-sample" 
	$rsh "chmod 700 /tmp/viamillipede-sample"
 	$rsh "cd /tmp; ./viamillipede-sample rx $port verbose $verb  | zfs recv $target_ds  " 2> /tmp/verr &
	sshpid=$!
	sleep 1.8
	zfs send $ds  | dd bs=16k | ./viamillipede  verbose $verb $targets  $threads
	#vmpid=$!
	sleep 1.8
	#wait $vmpid
	sudo kill $sshpid $tdpid $vmpid
	cat /tmp/verr
	}
remotetest () {
	pwd
	pkill viamillipede
	$rsh "pkill viamillipede-sample " 
	cat viamillipede |  $rsh "cat - > /tmp/viamillipede-sample" &
	$rsh "rm  -f /tmp/junk" &
	#sudo tcpdump -i em0 -s0 -w /tmp/mili.pcap host $host and port $port  &
	tdpid=$!
	$rsh "chmod 700 /tmp/viamillipede-sample"
 	$rsh "cd /tmp; setenv millipede_deserialiser ' /bin/cat - ';   ./viamillipede-sample rx $port verbose $verb  > /tmp/junk  " 2> /tmp/verr &
	sshpid=$!
	#there is a splitsecond race while listeners are onlined; please excuse the gap
	sleep 1.7 
	viamillipede  verbose $verb $targets threads 9  < $sample &
	vmpid=$!
	sleep 1.7 
	#kill -s INFO $vmpid
	#sleep 10.7 
	wait $vmpid
	sudo kill $sshpid $tdpid $vmpid
	cat /tmp/verr
	set rem_md=`$rsh " md5 -q /tmp/junk"`
	set     md=`md5 -q $sample`
	if [ $md  -eq $rem_md ]; then 
		banner -w 40  pass
	else 
		banner -w 40 fail

	fi
	
	
}

ncref () {
	$rsh "pkill -f ln -l 12323 ; cd /tmp/; rm -f junk"
	$rsh "  nc -l 12323 > /tmp/junk " &
	sshpid=$!
	sleep 1.3;
	time   dd if=$sample bs=16k |  nc -N $host 12323  
	$rsh " md5 -q /tmp/junk"
	       md5 -q $sample
	wait $sshpid
	kill $sshpid
}

localtest () { 
	pkill viamillipede
	rm -f out.test
	rm -f rand.out
	./viamillipede rx 12123  verbose $verb > /tmp/rand.out &
	sleep 0.75
	cat $sample | ./viamillipede tx localhost 12123  verbose $verb
	sleep 0.75
	diff rand.payload rand.out  
}


#zstreamref
zstreamremote
#ncref
#localtest
#remotetest 
