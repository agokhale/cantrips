#!/bin/sh
verb="4"
rm -f out.test
./viamillipede rx 12123  verbose $verb > rand.out &
rxpid=$!
echo rxpid $rxpid

sleep  2

echo -n payload bytes:
cat rand.payload | ./viamillipede tx localhost 12123  verbose $verb

sleep 2
#kill $rxpid 
diff rand.payload rand.out
wc  -c rand.payload rand.out
