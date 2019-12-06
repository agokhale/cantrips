#!/bin/sh -x
#grapt  [rows] [cols] points

trpp() {
echo bye
exit 0;
}
trap trpp KILL INT TERM


sc_rows=`tput lines`
sc_col=`tput cols`
ros=${1:-15}
col=${2:-80}
histdepth=${2:-120}

while true
do
        clear
        tail -$histdepth /tmp/networkload.history | networkloaddelta.awk -v select=rx | xyplot.awk -v rows=$ros -v cols=$col
        tail -$histdepth /tmp/networkload.history | networkloaddelta.awk -v select=tx | xyplot.awk -v rows=$ros -v cols=$col 
        sleep 1

done

