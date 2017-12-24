#!/bin/sh -x
verb=${1:-4}
user='xpi'
host='delerium'
port=12322
targets="tx delerium $port tx 192.168.239.250 $port"
#host='localhost'
rsh="ssh $user@$host "
sample="rand100.payload"

remotetest () {
	pwd
	export millipede_serializer=" /bin/cat -   "
	#export millipede_deserialiser=" /bin/cat - "
	echo -n rtt
	pkill viamillipede
	$rsh "pkill viamillipede-sample ; rm  -f /tmp/junk"
	cat viamillipede |  $rsh "cat - > /tmp/viamillipede-sample"
	sudo tcpdump -i em0 -s0 -w /tmp/mili.pcap host $host and port $port  &
	tdpid=$1
	$rsh "chmod 700 /tmp/viamillipede-sample"
 	$rsh "cd /tmp; setenv millipede_deserialiser ' /bin/cat - ';   ./viamillipede-sample rx $port verbose $verb  > /tmp/junk  " 2> /tmp/verr &
	sshpid=$!
	#there is a splitsecond race while listeners are onlined; please excuse the gap
	sleep 1.7 
	viamillipede  verbose $verb $targets threads 9  < $sample &
	vmpid=$!
	sleep 1.7 
	kill -s INFO $vmpid
	#sleep 10.7 
	wait $vmpid
	sudo kill $sshpid $tdpid $vmpid
	cat /tmp/verr
	$rsh " md5 -q /tmp/junk"
	       md5 -q $sample
	
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
	./viamillipede rx 12123  verbose $verb > rand.out &
	sleep 0.75
	cat rand.payload | ./viamillipede tx localhost 12123 tx ka  verbose $verb
	sleep 0.75
	diff rand.payload rand.out  
}


time $rsh " echo aack"
ncref
remotetest 
