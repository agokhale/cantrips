#!/bin/sh
# fast psurando generated file, much  faster than /dev/urandom 
# psurando.sh /out/path 1(g)

tpath=$1
gigs=$2

if [ $# -leq 2 ]; then
        exit -4
fi
echo writing psurandom $tpath with $gigs G of payload
sleep 0.3
dd if=/dev/zero bs=1G count=$gigs | openssl enc -aes-128-cbc -k swordfiiish > $tpath


