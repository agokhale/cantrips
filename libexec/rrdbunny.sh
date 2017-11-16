#!/bin/sh
# show rrd data in 
# $2...n  is the data source type
# $1 is the filename
# neat thing to do:
# #ls geom_stat/*latency*.rrd | xargs -n 1 -I % rrdbuuny.sh % read write delet

if [ $# -lt 1 ] ; then
	echo "args: "
	echo  " graph output rrd_bunny.sh a.file.rrd write read slope offset "
	echo " get valid dataset choices: rrd_bunny.sh "
	find . -type f | grep rrd |  xargs -n 1 rrdbunny.sh
fi 

if [ $# -lt 2 ] ; then
	echo  "$1 available fields:"
	rrdtool info $1 | grep 'ds.*index'
	rrdtool info $1 | grep '^ds.*index' | sed 's/ds\[\(.*\)\].*/\1/' | xargs rrdbunny.sh $1
	exit
fi

rrd_infile=$1
shift
data_sources=$@

echo "file: $rrd_infile"
echo "sources: $data_sources"

defs=""
lines=""
cursor=1
for ds in $data_sources ; do
	echo "source: $cursor $ds "
	#convolve the data source cursor into a color that will not cause seizues or eyebleeds
	colorR=` dc -e "16o 16i D1  $cursor * EF % 10 + p "`
	colorG=` dc -e "16o 16i F5  $cursor * EF % 10 + p "`
	colorB=` dc -e "16o 16i 5A  $cursor * EF % 10 + p "`
	color="$colorR$colorG$colorB"
	cursor=$((cursor+=1))
	defs="$defs  DEF:bunny_$ds=$rrd_infile:$ds:AVERAGE"
	echo $defs
	lines="$lines  LINE$cursor:bunny_$ds#$color:bunniesper$rrd_infile$ds"
	echo $lines
done 

#
ra_idx=9 #average
#2weeks
ra_idx=11 #average
#ra_idx=1
#4 days
ra_idx=3
#1 day
#ra_idx=1
#ra_idx=7

#get epoch timestamps
first_ts=`rrdtool first --rraindex $ra_idx $rrd_infile`
##last does not take rraindex -as , or last is last
last_ts=`rrdtool last $rrd_infile` 

#shrink the view window by some hours
first_ts=$(($first_ts - (3600 * 2)))
last_ts=$(($last_ts - (3600 * 16)))

echo "$first_ts to $last_ts"
echo 'control q to quit xv'
rrdtool graph - --imgformat PNG \
	-t "bunnies as of  $first_ts ` date -r $first_ts` - $last_ts `date -r $last_ts` "  \
	$defs \
	--start  $first_ts \
	--step 1 \
	--end  $last_ts \
	$lines \
	--color CANVAS#000000 --color BACK#000000 --color FONT#FFFFFF \
	--width 3080 --height 1600  \
	| xv - 

#	--width 1080 --height 700  | xv - 
#	--start `rrdtool first --rraindex $ra_idx $rrd_infile` --step 1 \
#	DEF:bunny=$rrd_infile:write:AVERAGE \
#	LINE1:bunny#60FF6F:"bunnies/femptofornight \l" \
