#!/bin/sh


trpp() {
echo bye
echo networkloadgraph.sh   [rows] [cols] [npoints] [iface]
exit 0;
}
trap trpp KILL INT TERM


sc_rows=`tput lines`
sc_col=`tput cols`
ros=${1:-18}
col=${2:-80}
histdepth=${3:-1600}
fil="/tmp/networkload.history"
all_ifaces=`tail -100  $fil | awk '// { print $2} ' | sort | uniq`

ifaces=${4:-$all_ifaces}
txrx=${5:-tx rx}
 

echo Interface $ifaces

while true
do
        clear
	for iface_c in $ifaces; do
		for d_c in $txrx; do
			echo $iface_c $d_c
			tail -$histdepth /tmp/networkload.history \
				| networkloaddelta.awk -v select=$d_c -v iface=$iface_c \
				| xyplot.awk -v rows=$ros -v cols=$col
		done
	done
	sleep 1

done

