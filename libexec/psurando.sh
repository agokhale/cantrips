#!/bin/sh
# fast psurando generated file, much  faster than /dev/urandom 
# not suitable for any cryptographic purpose; but this output will fool dedup and compression techniques. 


gigs=$1

cyphers="aes-128-cbc       aes-128-ecb       aes-192-cbc       aes-192-ecb       aes-256-cbc       aes-256-ecb       aria-128-cbc      aria-128-cfb      aria-128-cfb1     aria-128-cfb8     aria-128-ctr      aria-128-ecb      aria-128-ofb      aria-192-cbc      aria-192-cfb      aria-192-cfb1     aria-192-cfb8     aria-192-ctr      aria-192-ecb      aria-192-ofb      aria-256-cbc      aria-256-cfb      aria-256-cfb1     aria-256-cfb8     aria-256-ctr      aria-256-ecb      aria-256-ofb      base64 "

if [ $# -lt 1 ]; then
	echo  "psudorando.sh <sizeinGiB> [ password ] "
	echo  "psurando.sh 30 | dpv 30000024000:wat -o /dev/null"
	echo  "use a password for reproducable output"
        exit -4
fi


test_pallet() {
#	set -x
	for cy in $cyphers; do
		tim=`time dd if=/dev/zero bs=100m count=10  | openssl enc -${cy} -k swordfiiish > /dev/null`  
		echo "result: $cy  $tim"
	done
}

echo writing psurandom $tpath with $gigs G of payload
#test_pallet

candidatepaswd=swordfiiish`date +"%s"`
passwd=${2:-$candidatepaswd}
echo $passwd > /tmp/lastpsudoranopasswd
dd if=/dev/zero bs=1G count=$gigs | openssl enc -aes-128-cbc -k ${passwd} -S 5A -iter 1
