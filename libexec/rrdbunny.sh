#!/bin/sh 


# show rrd data in 
# $2...n  is the data source type
# $1 is the filename
# neat thing to do:
# #ls geom_stat/*latency*.rrd | xargs -n 1 -I % rrdbuuny.sh % read write delet


colorburst()
{
	#generate a color from an input
	#convolve the data source cursor into a color that will not cause seizues or eyebleeds
	colorR=` dc -e "16o 16i A1  $1 * EF % 10 + p "`
	colorG=` dc -e "16o 16i F5  $1 * D8 % 10 + p "`
	colorB=` dc -e "16o 16i AF  $1 * EF % 10 + p "`
	color="$colorR$colorG$colorB"
	echo gencolor:$1 $color
}

if [ $# -lt 1 ] ; then
	cat  << asdf
	rrdbunny.sh graph output: rrdbunny.sh a.file*.rrd

	knobs for turning are provided by getenv: 

setenv RRDBUNNY_RESOLUTION " --width 3800 --height 1600 "

#shrink the view window by some hours
setenv RRDBUNNY_SHRINK_START 0
setnv RRDBUNNY_SHRINK_STOP  0
#desination override
setenv RRDBUNNY_OUTPIPE  " xv - " 
#set timescale
setenv  RRDBUNNY_TIMESCALE  6

##
#ra_idx=0 #3 hours
#ra_idx=1 #3 hours
#ra_idx=2 #3  hours
#ra_idx=3 #24 hours
#ra_idx=4 #24 hours
#ra_idx=5 #24 hours
#ra_idx=6 #7*(24) hours
#ra_idx=7 #7*(24) hours
#ra_idx=8 #7*(24) hours
#ra_idx=9  # 1 month 
#ra_idx=10 # 1 month 
#ra_idx=11 # 1 month 
#ra_idx=12 # 1 year 

	
asdf
	exit
fi 


infiles=$@

ra_index=${RRDBUNNY_TIMESCALE:-"6"}
export RRDBUNNY_TIMESCALE

rrd_infile=$1
#get epoch timestamps
first_ts=`rrdtool first --rraindex $ra_index $rrd_infile`
#last does not take rraindex -as , or last is last
last_ts=`rrdtool last $rrd_infile` 
echo "view window from$first_ts `date -r $first_ts` to: $last_ts `date -r $last_ts`"

#shrink the view window by some hours
shrink_start=${RRDBUNNY_SHRINK_START:-"0"}
shrink_stop=${RRDBUNNY_SHRINK_STOP:-"0"}
export RRDBUNNY_SHRINK_STOP
export RRDBUNNY_SHRINK_START
first_ts=$((  $first_ts + (3600 * (shrink_start) )    ))
last_ts=$((    $last_ts - (3600 * (shrink_stop ) )    ))

resolution=${RRDBUNNY_RESOLUTION:-" --width 800 --height 600 "}
options=${RRDBUNNY_OPTIONS:-" --grid-dash 1:3  "}
export RRBDUNNY_RESOLUTION
echo $resolution
output_pipeline=${RRDBUNNY_OUTPIPE:-" xv - "}
export RRDBUNNY_OUTPIPE
echo $output_pipeline
echo 'control q to quit xv'

defs=""
lines=""
filenumber=1;
for file_cursor in $infiles; do 

	echo "scan $file_cursor looking for datasourrces  file: $filenumber"
	#get data sources
	data_sources=`rrdtool info $file_cursor | grep '^ds.*index' | sed 's/ds\[\(.*\)\].*/\1/'`
	dsnumber=1
	for ds_cursor in $data_sources; do 
		#scan the data sources in this file
		uniqueds=$(((filenumber * 16) + (dsnumber) ))
		colorburst $uniqueds
		echo "   $uniqueds ds$dsnumber: $ds_cursor $color"
		legend_text="$file_cursor$ds_cursor"
		legend_max="$legend_text-max"
		legend_min="$legend_text-min"
		defs=" DEF:bunny$uniqueds-max=$file_cursor:$ds_cursor:MAX $defs "
		defs=" DEF:bunny$uniqueds-min=$file_cursor:$ds_cursor:MIN $defs "
		lines=" LINE1:bunny$uniqueds-max#$color:'$legend_max':STACK $lines " 
		colorburst $((uniqueds+1))
		lines=" LINE1:bunny$uniqueds-min#$color:'$legend_min':dashes $lines " 
		#lines=" AREA:bunny$uniqueds-min#$color:'$legend_min' $lines " 
		#LINE1:bunny67-min#219CCC:'bnnydelete-max'

		dsnumber=$((dsnumber + 1))
	done
	
	filenumber=$((filenumber + 1))	

done #infile scanning
echo done infile scanning 
echo  $defs
echo $lines

rrdtool graph - --imgformat PNG \
	-t "bunnies as of  $first_ts ` date -r $first_ts` - $last_ts `date -r $last_ts` "  \
	$defs \
	--start  $first_ts \
	--step 1 \
	--end  $last_ts \
	$lines       \
	--color CANVAS#000000 --color BACK#000000 --color FONT#FFFFFF \
	$resolution  $options \
	| $output_pipeline
echo fin 
exit 0
#shift
#data_sources=$@
#
#echo "file: $rrd_infile"
#echo "sources: $data_sources"
#
#defs=""
#lines=""
#cursor=1
#for ds in $data_sources ; do
#	## loop thourough the datasources and build up 
#	echo "source: $cursor $ds "
#	#convolve the data source cursor into a color that will not cause seizues or eyebleeds
#	colorR=` dc -e "16o 16i D1  $cursor * EF % 10 + p "`
#	colorG=` dc -e "16o 16i F5  $cursor * EF % 10 + p "`
#	colorB=` dc -e "16o 16i 5A  $cursor * EF % 10 + p "`
#	color="$colorR$colorG$colorB"
#	cursor=$((cursor+=1))
#	defs="$defs  DEF:bunny_$ds=$rrd_infile:$ds:AVERAGE"
#	echo $defs
#	lines="$lines  LINE$cursor:bunny_$ds#$color:bunniesper$rrd_infile$ds"
#	echo $lines
#done 
#
##
#ra_idx=0 #3 hours
#ra_idx=1 #3 hours
#ra_idx=2 #3  hours
#ra_idx=3 #24 hours
#ra_idx=4 #24 hours
#ra_idx=5 #24 hours
#ra_idx=6 #7*(24) hours
#ra_idx=7 #7*(24) hours
#ra_idx=8 #7*(24) hours
#ra_idx=9  # 1 month 
#ra_idx=10 # 1 month 
#ra_idx=11 # 1 month 
#ra_idx=12 # 1 year 
#ra_idx=13 # 1 year 
#ra_idx=14 # 1 year 
#
#
#ra_idx=5 
#
##get epoch timestamps
#first_ts=`rrdtool first --rraindex $ra_idx $rrd_infile`
###last does not take rraindex -as , or last is last
#last_ts=`rrdtool last $rrd_infile` 
#
##shrink the view window by some hours
##first_ts=$((  $first_ts + (3600 * (0) )    ))
##last_ts=$((    $last_ts - (3600 * (0) )       ))
#
#echo "$first_ts `date -r $first_ts` to $last_ts `date -r $last_ts`"
#echo 'control q to quit xv'
#rrdtool graph - --imgformat PNG \
#	-t "bunnies as of  $first_ts ` date -r $first_ts` - $last_ts `date -r $last_ts` "  \
#	$defs \
#	--start  $first_ts \
#	--step 1 \
#	--end  $last_ts \
#	$lines \
#	--color CANVAS#000000 --color BACK#000000 --color FONT#FFFFFF \
#	--width 3080 --height 1600  \
#	| xv - 
#
##	--width 1080 --height 700  | xv - 
##	--start `rrdtool first --rraindex $ra_idx $rrd_infile` --step 1 \
##	DEF:bunny=$rrd_infile:write:AVERAGE \
##	LINE1:bunny#60FF6F:"bunnies/femptofornight \l" \
