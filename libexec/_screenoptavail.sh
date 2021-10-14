#!/bin/sh -e

# are there screens? fi so -dr else -S 

screencount=`screen -ls |  grep ached | wc -l `
if [ ${screencount} -gt 0 ]; then 
	echo " -dr "
else 
	echo " -S "
fi
