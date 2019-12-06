#!/bin/sh 

if [ $# -lt 2 ]; then 
	echo "monitor a path for changes reflected in stat(1)"
	echo "trap.sh <monitor_path> <what_to_run_with_that_path>"
	exit 2
fi
ipath=$1
istat=`stat $1`
nstat=$istat
while true; do
	sleep 3
	echo -n '.'
	nstat=`stat $1`
	echo -n ""
	case $istat in 
		$nstat) continue;;
		*) echo diff;   $2 $1 ; exit 0;;
	esac
done 

