#!/bin/sh -x

xwd > ${1}.xwd
convert ${1}.xwd ${1}.jpeg
xv ${1}.jpeg

