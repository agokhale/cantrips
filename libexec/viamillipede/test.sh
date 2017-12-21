#!/bin/sh -x
verb=${1:-4}
remotetest () {
	pwd
	user='xpi'
	host='delerium'
	rsh="ssh $user@$host "
	sample="rand1.payload"
	echo -n rtt
	time $rsh " echo aaack"
	$rsh "pkill viamillipede-sample ; rm  -f /tmp/junk"
	cat viamillipede |  $rsh "cat - > /tmp/viamillipede-sample"
 	$rsh "cd /tmp; ./viamillipede-sample rx 12323 verbose 15  > /tmp/junk  " 2> /tmp/verr &
	sshpid=$!
	sleep 0.7 
	time viamillipede tx delerium 12323 verbose  5  < $sample
	sleep 0.7 
	$rsh " md5 -q /tmp/junk"
	md5 -q $sample
	kill $sshpid
	
}

remotetest 

localtest () { 
	pkill viamillipede
	rm -f out.test
	rm -f rand.out
	./viamillipede rx 12123  verbose $verb > rand.out &
	#there is a splitsecond race while listeners are online; please excuse the gap
	sleep 0.75
	cat rand.payload | ./viamillipede tx localhost 12123  verbose $verb
	sleep 0.75
	diff rand.payload rand.out  
}


