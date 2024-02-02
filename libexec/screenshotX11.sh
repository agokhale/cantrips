#!/bin/sh -x


if [ $# -lt 1 ] ; then
	echo  usage: $0 output_name
	exit 1
fi
dir=${HOME}/tmp/screenshorts/
filstem=${dir}/${1}
mkdir -p ${HOME}/tmp/screenshorts/
xwd > ${filstem}.xwd
gm convert ${filstem}.xwd ${filstem}.jpeg
xv ${filstem}.jpeg

