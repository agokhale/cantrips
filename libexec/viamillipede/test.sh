#!/bin/sh -x
verb=${1:-4}
remotetest () {
	pwd
	user='xpi'
	host='delerium'
	targets="tx delerium 12323 tx 192.168.239.250 12323"
	#host='localhost'
	rsh="ssh $user@$host "
	sample="rand10.payload"
	echo -n rtt
	time $rsh " echo aaack"
	$rsh "pkill viamillipede-sample ; rm  -f /tmp/junk"
	cat viamillipede |  $rsh "cat - > /tmp/viamillipede-sample"
	$rsh "chmod 700 /tmp/viamillipede-sample"
 	$rsh "cd /tmp; ./viamillipede-sample rx 12323 verbose $verb  > /tmp/junk  " 2> /tmp/verr &
	sshpid=$!
	sleep 1.7 
	time viamillipede  verbose $verb $targets threads 16 verbose  $verb  < $sample
	sleep 0.7 
	cat /tmp/verr
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
	cat rand.payload | ./viamillipede tx localhost 12123 tx ka  verbose $verb
	sleep 0.75
	diff rand.payload rand.out  
}


