#!/bin/sh
# fast psurando generated file, much  faster than /dev/urandom 
# psurando.sh /out/path 1(g)

gigs=$1

if [ $# -ne 1 ]; then
	echo  "psudorando.sh <sizeinGiB>"
	echo  "psurando.sh 30 | dpv 30000024000:wat -o /dev/null"
        exit -4
fi
echo writing psurandom $tpath with $gigs G of payload
sleep 0.3
dd if=/dev/zero bs=1G count=$gigs | openssl enc -aes-128-cbc -k swordfiiish 


