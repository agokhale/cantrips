#!/bin/sh
verb=$1

pkill viamillipede
rm -f out.test
rm -f rand.out
./viamillipede rx 12123  verbose $verb > rand.out &

#there is a splitsecond race while listeners are online; please excuse the gap
sleep 0.75



cat rand.payload | ./viamillipede tx localhost 12123  verbose $verb
echo -n n 
sleep 0.75
diff rand.payload rand.out  
